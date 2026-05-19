import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/medication.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _notesController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _scheduleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final medication = Medication(
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      schedule: _scheduleController.text.trim(),
      notes: _notesController.text.trim(),
    );

    await DatabaseHelper().insertMedication(medication);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Medicamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Preencha os dados do medicamento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                label: 'Horários',
                hint: 'Ex: 08:00 e 20:00',
                icone: Icons.access_time,
                obrigatorio: true,
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
                label: Text(_saving ? 'Salvando...' : 'Salvar Medicamento'),
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
