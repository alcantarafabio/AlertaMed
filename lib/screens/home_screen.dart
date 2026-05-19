import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/medication.dart';
import '../models/patient.dart';
import '../widgets/patient_card.dart';
import 'add_medication_screen.dart';

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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: PatientCard(patient: _patient),
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

class _MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onDelete;

  const _MedicationCard({
    required this.medication,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Medicamento: ${medication.name}, dosagem: ${medication.dosage}, horários: ${medication.schedule}',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    _InfoRow(label: 'Horários', value: medication.schedule),
                    if (medication.notes.isNotEmpty)
                      _InfoRow(label: 'Obs.', value: medication.notes),
                  ],
                ),
              ),
              Semantics(
                label: 'Remover ${medication.name}',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 28, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Remover medicamento',
                ),
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
