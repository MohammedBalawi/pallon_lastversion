import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

import '../../../models/order_model.dart';
import '../../../models/task_model.dart';
import '../../Orders/view/order_details_view.dart';
import '../funcation/task_function.dart';

class TaskCard extends StatefulWidget {
  TaskModel model;
  TaskCard(this.model, {super.key});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getTaskReq();
  }

  Future<void> _getTaskReq() async {
    try {
      widget.model = await GetTaskReq(widget.model, context);
    } catch (_) {
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  double _calcProgress(String? task) {
    final t = (task ?? '').trim().toLowerCase();

    if (t == 'desginer' || t == 'designer') return 0.0;
    if (t == 'vendor') return 0.35;
    if (t == 'driver') return 0.7;

    return 1.0;
  }

  Color _progressColor(double p) {
    return (p >= 0.7)
        ? const Color(0xFF07933E)
        : (p > 0.0 ? const Color(0xFFF59E0B) : const Color(0xFFCE232B));
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.model.req;

    if (_loading || req == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final progress = _calcProgress(req.task);
    final percent = (progress * 100).round();
    final ringColor = _progressColor(progress);

    return InkWell(
      onTap: () {
        final order = OrderModel()..req = req;
        Get.to(
              () => OrderDetailsView(order),
          duration: const Duration(milliseconds: 450),
          transition: Transition.zoom,
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 86,
                decoration: BoxDecoration(
                  color: const Color(0xFF07933E),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (req.typeOfEvent ?? '').toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:  TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,

                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 4),

                    Text(
                      'For - ${(req.ownerOfevent ?? '').toString()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,

                        fontSize: 13.5,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Operation'.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,

                                  fontSize: 11.5,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Design'.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontFamily: ManagerFontFamily.fontFamily,

                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due date'.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,
                                  fontSize: 11.5,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                (req.date ?? '').toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:  TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,
                                  fontSize: 12.8,
                                  color: Color(0xFF111111),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              SizedBox(
                width: 74,
                height: 74,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 74,
                      height: 74,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$percent%',
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: ringColor,
                        ),
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
