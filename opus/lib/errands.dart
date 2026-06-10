import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Errands extends StatefulWidget {
  const Errands({super.key});

  @override
  State<Errands> createState() => _ErrandsState();
}

class _ErrandsState extends State<Errands> {
  final box = Hive.box("database");
  List<dynamic> todo = [];
  final TextEditingController _task = TextEditingController();

  @override
  void initState() {
    super.initState();
    todo = List<dynamic>.from(box.get("todo", defaultValue: []));
  }

  void _addTask() {
    // Use a bottom sheet that respects the keyboard
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _AddTaskSheet(
        onAdd: (text) {
          setState(() {
            todo.add({'task': text, 'isDone': false});
            box.put('todo', todo);
          });
        },
      ),
    );
  }

  int get _doneCount => todo.where((t) => t['isDone'] == true).length;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF000000),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF000000),
        border: null,
        automaticallyImplyLeading: false,
        middle: const Text(
          'Errands',
          style: TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: 0.3,
          ),
        ),
        trailing: todo.isEmpty
            ? null
            : Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$_doneCount/${todo.length}',
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Progress bar strip at top
            if (todo.isNotEmpty)
              Positioned(
                top: 0,
                left: 16,
                right: 16,
                child: _ProgressBar(done: _doneCount, total: todo.length),
              ),

            todo.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark_circle,
                      size: 36,
                      color: Color(0xFF3A3A3C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'All Clear',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF636366),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap + to add your first errand',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3A3A3C),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 100),
              itemCount: todo.length,
              itemBuilder: (context, index) {
                final item = todo[index];
                final isDone = item['isDone'] == true;

                return Dismissible(
                  key: ValueKey('${item['task']}_$index'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    return await showCupertinoDialog<bool>(
                      context: context,
                      builder: (_) => CupertinoAlertDialog(
                        title: const Text('Delete Errand'),
                        content: Text('Remove "${item['task']}"?'),
                        actions: [
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) {
                    setState(() {
                      todo.removeAt(index);
                      box.put('todo', todo);
                    });
                  },
                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: CupertinoColors.destructiveRed,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      CupertinoIcons.trash_fill,
                      color: CupertinoColors.white,
                      size: 18,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        todo[index]['isDone'] = !isDone;
                        box.put('todo', todo);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFF141414)
                            : const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDone
                              ? const Color(0xFF2C2C2E)
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isDone
                                  ? CupertinoIcons.check_mark_circled_solid
                                  : CupertinoIcons.circle,
                              key: ValueKey(isDone),
                              color: isDone
                                  ? CupertinoColors.systemGreen
                                  : const Color(0xFF48484A),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item['task'],
                              style: TextStyle(
                                fontSize: 15,
                                color: isDone
                                    ? const Color(0xFF48484A)
                                    : CupertinoColors.white,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                decorationColor:
                                const Color(0xFF48484A),
                              ),
                            ),
                          ),
                          if (!isDone)
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(
                                CupertinoIcons.chevron_left_slash_chevron_right,
                                color: Color(0xFF3A3A3C),
                                size: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Floating + button
            Positioned(
              bottom: 28,
              right: 24,
              child: GestureDetector(
                onTap: _addTask,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(27),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.white.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.add,
                    color: CupertinoColors.black,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Keyboard-Aware Add Task Sheet ──────────────────────────────────────────

class _AddTaskSheet extends StatefulWidget {
  final void Function(String) onAdd;
  const _AddTaskSheet({required this.onAdd});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus after the sheet animates in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Keyboard-safe: pad bottom by keyboard height
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A3A3C),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'New Errand',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),

            CupertinoTextField(
              controller: _ctrl,
              focusNode: _focus,
              placeholder: 'What needs to be done?',
              placeholderStyle:
              const TextStyle(color: Color(0xFF48484A), fontSize: 15),
              style:
              const TextStyle(color: CupertinoColors.white, fontSize: 15),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
              ),
              onSubmitted: (_) => _submit(),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _submit,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Add',
                          style: TextStyle(
                            color: CupertinoColors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Progress Bar Widget ──────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int done;
  final int total;
  const _ProgressBar({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : done / total;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: pct,
          minHeight: 2,
          backgroundColor: const Color(0xFF2C2C2E),
          valueColor: AlwaysStoppedAnimation<Color>(
            pct == 1.0
                ? CupertinoColors.systemGreen
                : CupertinoColors.activeBlue,
          ),
        ),
      ),
    );
  }
}