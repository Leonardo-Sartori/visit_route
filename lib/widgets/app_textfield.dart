import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextfield extends StatelessWidget {
  String text;
  bool? invisible;
  TextEditingController? controller;
  TextInputAction? textInputAction;
  FocusNode? focusNode;
  FocusNode? nextFocus;
  TextAlign textAlign;
  int? maxLines;
  bool required;
  bool? readOnly;
  bool autoFocus;
  TextInputType? inputType = TextInputType.text;
  TextCapitalization textCapitalization;
  ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? maskFormatter;

  AppTextfield(this.text, this.textCapitalization,
      {Key? key, this.invisible,
      this.controller,
      this.onChanged,
      this.maxLines,
      this.required = true,
      this.autoFocus = false,
      this.textInputAction,
      this.focusNode,
      this.readOnly = false,
      this.nextFocus,
      this.textAlign = TextAlign.start,
      this.validator,
      this.inputType,
      this.maskFormatter,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: TextFormField(
        inputFormatters: maskFormatter,
        onChanged: onChanged,
        autofocus: autoFocus,
        controller: controller,
        // validator: required ? _validRequired : null,
        validator: validator,
        textInputAction: textInputAction,
        focusNode: focusNode,
        maxLines: maxLines,
        readOnly: readOnly!,
        textCapitalization: textCapitalization,
        onFieldSubmitted: (String text) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        },
        textAlign: textAlign,
         decoration: InputDecoration(
           suffixIcon: invisible != null ? IconButton(
              icon: Icon(invisible! ? Icons.visibility : Icons.visibility_off),
              onPressed: (){
                invisible = !invisible!;
                (context as Element).markNeedsBuild();
              },
              color: Colors.black,
            ) : null,
            enabledBorder: OutlineInputBorder( 
              borderRadius: BorderRadius.circular(5.0),
               borderSide: const BorderSide(color: Colors.black, width: 1.0)
              ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(color: Colors.black, width: 1.0),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
            labelText: text,
            labelStyle: const TextStyle(
              fontSize: 15,
              color: Colors.black
            ),
          ),
        obscureText: invisible != null ? invisible! : false,
        keyboardType: inputType,
       
      ),
    );
  }
}
