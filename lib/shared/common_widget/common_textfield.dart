import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rental/shared/theme/app_color.dart';


class CommonTextFormField extends StatelessWidget {

  final TextEditingController controller;
  final IconData? icon;
  final int minimumLine;
  final String hint;
  final Function(String value)? onChange;
  final bool isPassword;
  final IconData? suffix;
  final TextInputType inputType;
  final VoidCallback? onChangePasswordView;
  final bool isShow;
  final List<TextInputFormatter>? inputFormatters;


  const CommonTextFormField({super.key,required this.controller,this.icon,this.minimumLine=1,required this.hint,this.onChange,this.isPassword=false,this.suffix,this.inputType=TextInputType.text,this.onChangePasswordView,this.isShow=false,this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller,
        inputFormatters: inputFormatters,
        minLines: minimumLine,
        keyboardType: inputType,
        maxLines: minimumLine,
        onChanged: onChange,
        obscureText: isShow,
        obscuringCharacter: "*",
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.black),
          border: InputBorder.none,
          prefixIcon: Icon(icon,color: primaryColor,size: 18,),
          suffixIcon: isPassword?IconButton(onPressed: onChangePasswordView, icon: Icon(suffix,color: brown,size: 18,)):null,
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none
          ),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none
          ),
          errorBorder: OutlineInputBorder(
              borderSide: BorderSide.none
          ),
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none
          ),

        ),
      ),);
  }
}
