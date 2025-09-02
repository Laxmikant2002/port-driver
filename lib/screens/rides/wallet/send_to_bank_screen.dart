import 'package:flutter/material.dart';
import 'package:driver/widgets/essentials/customTextField.dart';

class SendToBank extends StatelessWidget {
  SendToBank({super.key});

  final Map<String, dynamic> formData = {
    'amount': '',
    'acc_number': '',
    'bank_name': '',
    'ifsc_code': '',
    
  };

  void submit() {
    print(formData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Send Money',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Text(
            'Send earned money to bank',
            style: TextStyle(
              fontSize: 17,
              color: Colors.black54,
              // color: AppColors.labelFont,
            ),
          ),
          // const Divider( thickness: 10, color: Colors.transparent,),
          const SizedBox(
            height: 20,
          ),
          // CustomTextField(label: 'Amount to Send'),
          CustomTextField(
            label: 'Amount to Send',
            hintText: 'Amount to Send',
            inputType: TextInputType.number,
            onChanged: (String value) {
              formData['amount'] = value;
            },
          ),
          const Divider(
            thickness: 3,
            color: Color.fromARGB(255, 229, 229, 229),
          ),
          CustomTextField(
            label: 'Account Number',
            hintText: 'Account Number',
            inputType: TextInputType.number,
            onChanged: (String value) {
              formData['acc_number'] = value;
            },
          ),
          CustomTextField(
            label: 'Bank Name',
            hintText: 'Bank Name',
            inputType: TextInputType.text,
            onChanged: (String value) {
              formData['bank_name'] = value;
            },
          ),
          CustomTextField(
            label: 'IFSC Code',
            hintText: 'IFSC Code',
            inputType: TextInputType.text,
            onChanged: (String value) {
              formData['ifsc_code'] = value;
            },
          ),
          // CustomTextField(label: 'Bank Name'),
          // CustomTextField(label: 'IFSC Code'),
        ],
      ),
      floatingActionButton: Container(
        height: 60,
        padding: const EdgeInsets.only(left: 20, right: 20),
        color: Colors.white,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: submit,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.black87,
          ),
          child: const Text(
            'Send Money',
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
