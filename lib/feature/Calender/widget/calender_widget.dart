import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

import '../../../models/task_model.dart';
import '../../../models/user_model.dart';
import '../../MainScreen/function/main_function.dart';
import '../../Tasks/funcation/task_function.dart';
import '../../Tasks/widget/task_card.dart';

class CalenderWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CalenderWidget();
  }
}

class _CalenderWidget extends State<CalenderWidget> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;
  List<TaskModel> tasks = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel userModel = UserModel(
    doc: "doc",
    email: "email",
    phone: "phone",
    name: "name",
    pic: "pic",
    type: "type",
  );

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _selectedDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    GetUserType();
  }

  void GetUserType() async {
    if (_auth.currentUser != null) {
      UserModel? user = await GetUserData(_auth.currentUser!.uid);
      setState(() {
        userModel = user!;
      });
    }
    starttask();
  }

  void starttask() async {
    if (userModel.type == "Admin") {
      tasks = await GetAdminTask(_selectedDate, context);
    } else {
      tasks = await GetUserTaskDate(_selectedDate, context);
    }
    setState(() {});
  }

  void _changeMonth(int change) {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month + change, 1);
    });
  }

  void _selectDay(int day) async {
    DateTime date = DateTime(_currentMonth.year, _currentMonth.month, day);
    if (userModel.type == "Admin") {
      tasks = await GetAdminTask(date, context);
    } else {
      tasks = await GetUserTaskDate(date, context);
    }
    setState(() {
      _selectedDate = date;
    });
  }

  String _monthName(int month) {
    switch (month) {
      case 1:
        return 'January'.tr;
      case 2:
        return 'February'.tr;
      case 3:
        return 'March'.tr;
      case 4:
        return 'April'.tr;
      case 5:
        return 'May'.tr;
      case 6:
        return 'June'.tr;
      case 7:
        return 'July'.tr;
      case 8:
        return 'August'.tr;
      case 9:
        return 'September'.tr;
      case 10:
        return 'October'.tr;
      case 11:
        return 'November'.tr;
      case 12:
        return 'December'.tr;
      default:
        return '';
    }
  }

  int _getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
        return 29;
      }
      return 28;
    }
    return DateTime(year, month + 1, 0).day;
  }

  int _getStartingDayOfWeek(int year, int month) {
    return DateTime(year, month, 1).weekday % 7;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final normalizedSelectedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final selectedColor = const Color(0xFF07933E);
    final todayBorderColor = const Color(0xFFCE232B);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF07933E),
                    Color(0xFF007530),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 100,
                    left: screenWidth * 0.08,
                    child: Text(
                      'Calender'.tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left,
                            color: Colors.black87),
                        onPressed: () => _changeMonth(-1),
                      ),
                      Text(
                        '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF000000),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right,
                            color: Colors.black87),
                        onPressed: () => _changeMonth(1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        'Sunday'.tr,
                        'Monday'.tr,
                        'Tuesday'.tr,
                        'Wednesday'.tr,
                        'Thursday'.tr,
                        'Friday'.tr,
                        'Saturday'.tr,
                      ].map(
                            (day) => Expanded(
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,
                                  fontWeight: FontWeight.w600,
                                  fontSize: screenWidth * 0.03,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ),


                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.0,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                      ),
                      itemCount: _getDaysInMonth(
                          _currentMonth.year, _currentMonth.month) +
                          _getStartingDayOfWeek(
                              _currentMonth.year, _currentMonth.month),
                      itemBuilder: (context, index) {
                        final startingDay = _getStartingDayOfWeek(
                            _currentMonth.year, _currentMonth.month);

                        if (index < startingDay) {
                          return const SizedBox.shrink();
                        }

                        final day = index - startingDay + 1;
                        final dateToCheck = DateTime(
                            _currentMonth.year, _currentMonth.month, day);

                        final isToday =
                            dateToCheck.year == DateTime.now().year &&
                                dateToCheck.month == DateTime.now().month &&
                                dateToCheck.day == DateTime.now().day;

                        final isSelected = dateToCheck == normalizedSelectedDate;

                        final normalBackgroundColor = Colors.white;
                        final normalTextColor = const Color(0xFF000000);

                        return GestureDetector(
                          onTap: () => _selectDay(day),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? selectedColor
                                  : normalBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                              border: isToday
                                  ? Border.all(
                                color: isSelected
                                    ? selectedColor
                                    : todayBorderColor,
                                width: isSelected ? 0 : 2,
                              )
                                  : Border.all(
                                color: isSelected
                                    ? selectedColor
                                    : Colors.transparent,
                                width: isSelected ? 2 : 0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.12),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                                if (isSelected)
                                  BoxShadow(
                                    color: selectedColor.withOpacity(0.4),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                day.toString(),
                                style: TextStyle(
                                  fontFamily: ManagerFontFamily.fontFamily,
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : (isToday
                                      ? todayBorderColor
                                      : normalTextColor),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    '${'Tasks for'.tr} ${_selectedDate.day} ${_monthName(_selectedDate.month)}',
                    style: TextStyle(
                      fontFamily: ManagerFontFamily.fontFamily,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF000000),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey[300],
                  ),

                  const SizedBox(height: 12),

                  tasks.isNotEmpty
                      ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 6.0),
                        child: TaskCard(tasks[index]),
                      );
                    },
                  )
                      : Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Text(
                        "You Don't Have Any Task".tr,
                        style: TextStyle(
                          fontFamily: ManagerFontFamily.fontFamily,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
