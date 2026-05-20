import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/patient.dart';
import '../theme/cores.dart';

class PatientFormScreen extends StatefulWidget {
  final Patient? patient;

  const PatientFormScreen({super.key, this.patient});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper();

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _idadeCtrl;
  late final TextEditingController _tipoSanguineoCtrl;
  late final TextEditingController _alergiasCtrl;
  late final TextEditingController _contatoEmergenciaCtrl;
  late final TextEditingController _nomeCuidadorCtrl;
  late final TextEditingController _telefoneCuidadorCtrl;
  late final TextEditingController _observacoesCtrl;

  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _nomeCtrl = TextEditingController(text: p?.name ?? '');
    _idadeCtrl = TextEditingController(text: p != null ? p.age.toString() : '');
    _tipoSanguineoCtrl = TextEditingController(text: p?.bloodType ?? '');
    _alergiasCtrl = TextEditingController(text: p?.allergies ?? '');
    _contatoEmergenciaCtrl = TextEditingController(text: p?.emergencyContact ?? '');
    _nomeCuidadorCtrl = TextEditingController(text: p?.caregiverName ?? '');
    _telefoneCuidadorCtrl = TextEditingController(text: p?.caregiverPhone ?? '');
    _observacoesCtrl = TextEditingController(text: p?.notes ?? '');
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _idadeCtrl.dispose();
    _tipoSanguineoCtrl.dispose();
    _alergiasCtrl.dispose();
    _contatoEmergenciaCtrl.dispose();
    _nomeCuidadorCtrl.dispose();
    _telefoneCuidadorCtrl.dispose();
    _observacoesCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    String? nullable(String s) => s.trim().isEmpty ? null : s.trim();

    final patient = Patient(
      name: _nomeCtrl.text.trim(),
      age: int.parse(_idadeCtrl.text.trim()),
      bloodType: nullable(_tipoSanguineoCtrl.text),
      allergies: nullable(_alergiasCtrl.text),
      emergencyContact: nullable(_contatoEmergenciaCtrl.text),
      caregiverName: nullable(_nomeCuidadorCtrl.text),
      caregiverPhone: nullable(_telefoneCuidadorCtrl.text),
      notes: nullable(_observacoesCtrl.text),
    );

    await _db.savePatient(patient);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.patient != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Paciente' : 'Cadastrar Paciente'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _secao('Dados do Paciente'),
            _Campo(
              label: 'Nome completo *',
              ctrl: _nomeCtrl,
              icon: Icons.person,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            _Campo(
              label: 'Idade *',
              ctrl: _idadeCtrl,
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe a idade';
                final n = int.tryParse(v.trim());
                if (n == null || n < 1 || n > 130) return 'Idade inválida';
                return null;
              },
            ),
            _Campo(
              label: 'Tipo sanguíneo',
              ctrl: _tipoSanguineoCtrl,
              icon: Icons.bloodtype_outlined,
              hint: 'Ex: A+, B-, O+, AB-',
            ),
            _Campo(
              label: 'Alergias',
              ctrl: _alergiasCtrl,
              icon: Icons.warning_amber_outlined,
              hint: 'Ex: dipirona, penicilina, látex',
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            _secao('Contato de Emergência'),
            _Campo(
              label: 'Contato de emergência',
              ctrl: _contatoEmergenciaCtrl,
              icon: Icons.emergency_outlined,
              hint: 'Nome e telefone',
              keyboardType: TextInputType.phone,
            ),
            _Campo(
              label: 'Nome do responsável / cuidador',
              ctrl: _nomeCuidadorCtrl,
              icon: Icons.favorite_outline,
            ),
            _Campo(
              label: 'Telefone do responsável',
              ctrl: _telefoneCuidadorCtrl,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            _secao('Observações'),
            _Campo(
              label: 'Observações gerais',
              ctrl: _observacoesCtrl,
              icon: Icons.notes_outlined,
              hint: 'Informações adicionais relevantes',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvando ? null : _salvar,
              child: _salvando
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Salvar paciente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secao(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppCores.primaria,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;

  const _Campo({
    required this.label,
    required this.ctrl,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
