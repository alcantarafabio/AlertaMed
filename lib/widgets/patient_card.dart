import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../theme/cores.dart';

class PatientCard extends StatelessWidget {
  final Patient? patient;

  const PatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    if (patient == null) {
      return _buildEmpty(context);
    }
    return _buildCard(context, patient!);
  }

  Widget _buildCard(BuildContext context, Patient p) {
    return Semantics(
      label: 'Ficha do paciente: ${p.name}, ${p.age} anos',
      child: Card(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        color: AppCores.primaria,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      p.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${p.age} anos',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              if (p.caregiverName != null && p.caregiverName!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(color: Colors.white38, height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cuidador(a): ${p.caregiverName}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: AppCores.superficie,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nenhum paciente cadastrado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppCores.textoPrimario,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Adicione as informações do paciente principal para facilitar o cuidado.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppCores.textoSecundario,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
