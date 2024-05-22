import 'package:flutter/material.dart';


Widget customHeightSizedBox(BuildContext context, {double? heightFactor, }) {
  return SizedBox(
    height: MediaQuery.of(context).size.height * heightFactor!,
  );
}
