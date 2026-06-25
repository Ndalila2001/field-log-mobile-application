import 'package:flutter/material.dart';

class FieldLogForm extends StatelessWidget {
  const FieldLogForm({
    super.key,
    required this.formKey,
    required this.speciesController,
    required this.countController,
    required this.latitudeController,
    required this.longitudeController,
    required this.notesController,
    required this.selectedPhotoNames,
    required this.onCaptureLocation,
    required this.onPickGalleryPhotos,
    required this.onCapturePhoto,
    required this.onRemovePhoto,
    required this.onSave,
    required this.requiredTextValidator,
    required this.positiveIntegerValidator,
    required this.coordinateValidator,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController speciesController;
  final TextEditingController countController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final TextEditingController notesController;
  final List<String> selectedPhotoNames;
  final VoidCallback onCaptureLocation;
  final VoidCallback onPickGalleryPhotos;
  final VoidCallback onCapturePhoto;
  final ValueChanged<int> onRemovePhoto;
  final VoidCallback onSave;
  final FormFieldValidator<String> requiredTextValidator;
  final FormFieldValidator<String> positiveIntegerValidator;
  final FormFieldValidator<String> coordinateValidator;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'New sighting',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('speciesField'),
                controller: speciesController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Species name',
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: requiredTextValidator,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('countField'),
                      controller: countController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Animal count',
                        prefixIcon: Icon(Icons.format_list_numbered),
                      ),
                      validator: positiveIntegerValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    tooltip: 'Capture current location',
                    onPressed: onCaptureLocation,
                    icon: const Icon(Icons.my_location),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: latitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        prefixIcon: Icon(Icons.explore),
                      ),
                      validator: coordinateValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: longitudeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        prefixIcon: Icon(Icons.explore_outlined),
                      ),
                      validator: coordinateValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPickGalleryPhotos,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Select photos'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCapturePhoto,
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Use camera'),
                    ),
                  ),
                ],
              ),
              if (selectedPhotoNames.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final entry in selectedPhotoNames.indexed)
                      InputChip(
                        avatar: const Icon(Icons.image, size: 16),
                        label: Text(entry.$2),
                        onDeleted: () => onRemovePhoto(entry.$1),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: notesController,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Notes / observations',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes),
                ),
                validator: requiredTextValidator,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('saveLogButton'),
                onPressed: onSave,
                icon: const Icon(Icons.save),
                label: const Text('Save local log'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
