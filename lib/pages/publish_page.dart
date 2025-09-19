import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/state.dart';
import '../models.dart';
import '../mock_data.dart';
import '../theme.dart';

class PublishPage extends ConsumerStatefulWidget {
  const PublishPage({super.key});
  @override
  ConsumerState<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends ConsumerState<PublishPage> {
  final _formKey = GlobalKey<FormState>();
  String? schoolId;
  String? garmentId;
  String? size;
  Condition condition = Condition.good;
  double price = 8.0;
  bool confirmGood = true;
  bool hasFix = false;
  String? fixText;
  bool hasInfo = false;
  String? extraInfo;

  @override
  void initState() {
    super.initState();
    final user = ref.read(appProvider).user;
    schoolId = user.defaultSchoolId;
  }

  Future<void> _showOnlyGoodDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Solo prendas en buen estado'),
        content: const Text(
            'Ahora mismo solo aceptamos prendas en buen estado.\n\n'
            'Si hay un desperfecto leve, descríbelo y sube una foto.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Entendido')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final school = schools.firstWhere((s) => s.id == (schoolId ?? state.selectedSchoolId));
    final garments = school.garments;

    final publishConditions = Condition.values
        .where((c) => (conditionLabels[c] ?? '').toLowerCase() != 'como nuevo')
        .toList();

    final canPublish = confirmGood && schoolId != null && garmentId != null && size != null;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: schoolId,
            isExpanded: true,
            dropdownColor: Colors.white,
            menuMaxHeight: 360,
            decoration: const InputDecoration(labelText: 'Colegio'),
            items: schools.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
            onChanged: (v) => setState(() => schoolId = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: garmentId,
            isExpanded: true,
            dropdownColor: Colors.white,
            menuMaxHeight: 360,
            decoration: const InputDecoration(labelText: 'Prenda'),
            items: garments.map((g) => DropdownMenuItem(value: g.id, child: Text(g.label))).toList(),
            onChanged: (v) => setState(() { garmentId = v; size = null; }),
            validator: (v) => v == null ? 'Selecciona una prenda' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey(garmentId),
            initialValue: size,
            isExpanded: true,
            dropdownColor: Colors.white,
            menuMaxHeight: 360,
            decoration: const InputDecoration(labelText: 'Talla'),
            items: (garmentId == null
                    ? const <String>[]
                    : garments.firstWhere((g) => g.id == garmentId).sizes)
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (garmentId == null) ? null : (v) => setState(() => size = v),
            validator: (v) => v == null ? 'Selecciona una talla' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Condition>(
            initialValue: condition,
            isExpanded: true,
            dropdownColor: Colors.white,
            menuMaxHeight: 360,
            decoration: const InputDecoration(labelText: 'Estado'),
            items: publishConditions
                .map((c) => DropdownMenuItem(value: c, child: Text(conditionLabels[c]!)))
                .toList(),
            onChanged: (v) => setState(() => condition = v ?? Condition.good),
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Precio (€)'),
            initialValue: price.toStringAsFixed(2),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => price = double.tryParse(v.replaceAll(',', '.')) ?? price,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Confirmo que la prenda está en buen estado'),
            subtitle: const Text('Rechazamos prendas rotas o con mal estado general'),
            value: confirmGood,
            onChanged: (v) async {
              if (!v) {
                setState(() => confirmGood = false);
                await _showOnlyGoodDialog();
              } else {
                setState(() => confirmGood = true);
              }
            },
          ),
          const SizedBox(height: 4),
          CheckboxListTile(
            title: const Text('La prenda tiene algún arreglo (bajos, gomas, etc.)'),
            value: hasFix,
            onChanged: (v) => setState(() => hasFix = v ?? false),
          ),
          if (hasFix)
            TextFormField(
              decoration: const InputDecoration(labelText: 'Describe el arreglo'),
              onChanged: (v) => fixText = v,
            ),
          const SizedBox(height: 4),
          CheckboxListTile(
            title: const Text('¿Algo que informar al comprador? (ej. pequeña mancha)'),
            value: hasInfo,
            onChanged: (v) {
              setState(() => hasInfo = v ?? false);
              if (v == true) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Consejo: sube una foto del detalle para generar confianza'),
                ));
              }
            },
          ),
          if (hasInfo)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Información adicional',
                hintText: 'Describe brevemente (máx. 120 caracteres)',
              ),
              maxLength: 120,
              onChanged: (v) => extraInfo = v,
            ),
          if (hasFix || hasInfo) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FBF9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGreenSoft),
              ),
              child: const Row(
                children: [
                  Icon(Icons.photo_camera_outlined, color: kGreen),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Recomendación: sube una foto del desperfecto para acelerar la venta.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined, color: kGreen),
            title: const Text('Añadir fotos del artículo'),
            subtitle: const Text('Usa imágenes reales; si no, pondremos una imagen de catálogo.'),
            onTap: () {},
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.white,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: !canPublish
                ? null
                : () {
                    if (!(_formKey.currentState?.validate() ?? false)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Completa la prenda y la talla')),
                      );
                      return;
                    }
                    final garmentLabel =
                        garments.firstWhere((g) => g.id == garmentId).label;
                    final listing = Listing.sample(
                      title: garmentLabel,
                      schoolId: schoolId!,
                      garmentId: garmentId!,
                      size: size!,
                      price: price,
                      condition: condition,
                      defects: [
                        if (hasFix && (fixText?.isNotEmpty ?? false)) 'Arreglo: \${fixText!}',
                        if (hasInfo && (extraInfo?.isNotEmpty ?? false)) extraInfo!,
                      ],
                    );
                    ref.read(appProvider.notifier).addListing(listing);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Anuncio publicado')),
                      );
                      Navigator.of(context).pop();
                    }
                  },
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Publicar'),
          )
        ],
      ),
    );
  }
}
