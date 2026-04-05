import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalculatorKeyboard extends StatelessWidget {
  final ValueChanged<String> onKeyTap;
  final VoidCallback? onBackspace;
  final VoidCallback? onClear;

  const CalculatorKeyboard({
    super.key,
    required this.onKeyTap,
    this.onBackspace,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      '7', '8', '9', '÷',
      '4', '5', '6', '×',
      '1', '2', '3', '-',
      '0', '.', '=', '+',
    ];

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              /// keys
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.36,
                child: GridView.builder(
                  itemCount: keys.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) {
                    final key = keys[index];
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero, // 🔥 default padding remove
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => onKeyTap(key),
                      child: Center(
                        child: Text(
                          key,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );

                  },
                ),
              ),

              /// bottom actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onClear,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('C', style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onBackspace,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.zero,
                      ),
                      child: Icon(Icons.backspace_outlined,color: Colors.white,),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.zero,
                      ),
                      child: Icon(Icons.done_rounded,color: Colors.white,),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}