import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/medication.dart';
import '../models/patient.dart';
import '../widgets/patient_card.dart';
import 'add_medication_screen.dart';
import 'patient_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Medication> _medications = [];
  Patient? _patient;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final meds = await _db.getMedications();
    final patient = await _db.getPatient();
    setState(() {
      _medications = meds;
      _patient = patient;
      _loading = false;
    });
  }

  Future<void> _deleteMedication(Medication med) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover medicamento?', style: TextStyle(fontSize: 20)),
        content: Text(
          'Deseja remover "${med.name}" da lista?',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(fontSize: 18)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover',
                style: TextStyle(fontSize: 18, color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && med.id != null) {
      await _db.deleteMedication(med.id!);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${med.name}" removido.')),
        );
      }
    }
  }

  Future<void> _navegarParaCadastro() async {
    final adicionou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
    );
    if (adicionou == true) _loadData();
  }

  Future<void> _editarMedicamento(Medication med) async {
    final editado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddMedicationScreen(medication: med)),
    );
    if (editado == true) _loadData();
  }

  Future<void> _navegarParaPaciente() async {
    final salvo = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PatientFormScreen(patient: _patient)),
    );
    if (salvo == true) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AlertaMed'),
        actions: [
          Semantics(
            label: 'Total de medicamentos cadastrados',
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_medications.length} med.',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarParaCadastro,
        icon: const Icon(Icons.add, size: 28),
        label: const Text('Adicionar'),
        tooltip: 'Adicionar novo medicamento',
      ),
    );
  }

  Widget _buildBody() {
    final temAlergias = _patient != null &&
        _patient!.allergies != null &&
        _patient!.allergies!.isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: PatientCard(patient: _patient, onEdit: _navegarParaPaciente),
        ),
        if (temAlergias)
          SliverToBoxAdapter(
            child: _AllergyAlert(allergies: _patient!.allergies!),
          ),
        if (_medications.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEstadoVazio(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 88),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final med = _medications[index];
                  return _MedicationCard(
                    medication: med,
                    onEdit: () => _editarMedicamento(med),
                    onDelete: () => _deleteMedication(med),
                  );
                },
                childCount: _medications.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.medication_outlined,
                size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            const Text(
              'Nenhum medicamento\ncadastrado ainda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text(
              'Toque em "Adicionar" para\ncadastrar seu primeiro medicamento.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllergyAlert extends StatelessWidget {
  final String allergies;

  const _AllergyAlert({required this.allergies});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Atenção: alergias do paciente: $allergies',
      child: Card(
        color: const Color(0xFFFFF8E1),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF8F00),
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ALERGIAS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      allergies,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MedicationCard({
    required this.medication,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Medicamento: ${medication.name}, dosagem: ${medication.dosage}, horário: ${medication.schedule}',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.medication,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medication.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    _InfoRow(label: 'Dosagem', value: medication.dosage),
                    _InfoRow(label: 'Horário', value: medication.schedule),
                    if (medication.frequency.isNotEmpty)
                      _InfoRow(label: 'Frequência', value: medication.frequency),
                    if (medication.notes.isNotEmpty)
                      _InfoRow(label: 'Obs.', value: medication.notes),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: 'Editar ${medication.name}',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          size: 22, color: Color(0xFF1565C0)),
                      onPressed: onEdit,
                      tooltip: 'Editar medicamento',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Semantics(
                    label: 'Remover ${medication.name}',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 22, color: Colors.red),
                      onPressed: onDelete,
                      tooltip: 'Remover medicamento',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Color(0xFF555555)),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
