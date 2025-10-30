import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../models/game.dart';
import '../providers.dart';

class EditGameScreen extends ConsumerStatefulWidget {
  final String? id; // null = new
  const EditGameScreen({super.key, this.id});

  @override
  ConsumerState<EditGameScreen> createState() => _EditGameScreenState();
}

class _EditGameScreenState extends ConsumerState<EditGameScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _title;
  late TextEditingController _platform;
  GameStatus _status = GameStatus.planned;
  int? _rating;
  double? _hours;
  DateTime? _startedAt;
  DateTime? _finishedAt;
  late TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _platform = TextEditingController(text: 'PC');
    _notes = TextEditingController();
    _loadIfEditing();
  }

  Future<void> _loadIfEditing() async {
    if (widget.id == null) return;
    final dao = ref.read(gameDaoProvider);
    final existing = await dao.getById(widget.id!);
    if (existing != null) {
      setState(() {
        _title.text = existing.title;
        _platform.text = existing.platform;
        _status = existing.status;
        _rating = existing.rating;
        _hours = existing.hours;
        _startedAt = existing.startedAt;
        _finishedAt = existing.finishedAt;
        _notes.text = existing.notes ?? '';
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _platform.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final initial = isStart ? (_startedAt ?? now) : (_finishedAt ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startedAt = picked;
        } else {
          _finishedAt = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(gameDaoProvider);
    final uuid = ref.watch(uuidProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Add game' : 'Edit game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _platform,
                decoration: const InputDecoration(labelText: 'Platform (e.g., PC, PS5, Switch)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a platform' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<GameStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: GameStatus.values.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.label),
                )).toList(),
                onChanged: (v) => setState(() => _status = v ?? GameStatus.planned),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Rating (0-10)'),
                keyboardType: TextInputType.number,
                initialValue: _rating?.toString(),
                onChanged: (v) => _rating = int.tryParse(v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Hours'),
                keyboardType: TextInputType.number,
                initialValue: _hours?.toString(),
                onChanged: (v) => _hours = double.tryParse(v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text('Started: ${Game.formatDate(_startedAt)}')),
                  TextButton(onPressed: () => _pickDate(context, true), child: const Text('Pick')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text('Finished: ${Game.formatDate(_finishedAt)}')),
                  TextButton(onPressed: () => _pickDate(context, false), child: const Text('Pick')),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final id = widget.id ?? uuid.v4();
                  final game = Game(
                    id: id,
                    title: _title.text.trim(),
                    platform: _platform.text.trim(),
                    status: _status,
                    rating: _rating,
                    hours: _hours,
                    startedAt: _startedAt,
                    finishedAt: _finishedAt,
                    notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
                  );
                  await dao.upsert(game);
                  if (context.mounted) context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
