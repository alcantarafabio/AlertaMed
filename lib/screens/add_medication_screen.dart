import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/medication.dart';

class AddMedicationScreen extends StatefulWidget {
  final Medication? medication;

  const AddMedicationScreen({super.key, this.medication});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  late final TextEditingController _scheduleController;
  late final TextEditingController _frequencyController;
  late final TextEditingController _notesController;
  bool _saving = false;

  bool get _isEdit => widget.medication != null;

  @override
  void initState() {
    super.initState();
    final m = widget.medication;
    _nameController     = TextEditingController(text: m?.name ?? '');
    _dosageController   = TextEditingController(text: m?.dosage ?? '');
    _scheduleController = TextEditingController(text: m?.schedule ?? '');
    _frequencyController = TextEditingController(text: m?.frequency ?? '');
    _notesController    = TextEditingController(text: m?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _scheduleController.dispose();
    _frequencyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final medication = Medication(
      id: widget.medication?.id,
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      schedule: _scheduleController.text.trim(),
      frequency: _frequencyController.text.trim(),
      notes: _notesController.text.trim(),
    );

    final db = DatabaseHelper();
    if (_isEdit) {
      await db.updateMedication(medication);
    } else {
      await db.insertMedication(medication);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Medicamento' : 'Novo Medicamento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEdit
                    ? 'Atualize os dados do medicamento'
                    : 'Preencha os dados do medicamento',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              _CampoTexto(
                controller: _nameController,
                label: 'Nome do medicamento',
                hint: 'Ex: Losartana',
                icone: Icons.medication,
                obrigatorio: true,
              ),
              const SizedBox(height: 16),
              _CampoTexto(
                controller: _dosageController,
                label: 'Dosagem',
                hint: 'Ex: 50mg',
                icone: Icons.local_pharmacy,
                obrigatorio: true,
              ),
              const SizedBox(height: 16),
              _CampoTexto(
                controller: _scheduleController,
                label: 'Horário',
                hint: 'Ex: 08:00 e 20:00',
                icone: Icons.access_time,
                obrigatorio: true,
              ),
              const SizedBox(height: 16),
              _CampoTexto(
                controller: _frequencyController,
                label: 'Frequência (opcional)',
                hint: 'Ex: 1x ao dia, 2x ao dia, A cada 8h',
                icone: Icons.repeat,
                obrigatorio: false,
              ),
              const SizedBox(height: 16),
              _CampoTexto(
                controller: _notesController,
                label: 'Observações (opcional)',
                hint: 'Ex: Tomar com água',
                icone: Icons.notes,
                obrigatorio: false,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save, size: 24),
                label: Text(_saving
                    ? 'Salvando...'
                    : _isEdit
                        ? 'Salvar alterações'
                        : 'Salvar Medicamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icone;
  final bool obrigatorio;
  final int maxLines;

  const _CampoTexto({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icone,
    required this.obrigatorio,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icone, size: 26),
      ),
      validator: obrigatorio
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Este campo é obrigatório';
              }
              return null;
            }
          : null,
    );
  }
}
