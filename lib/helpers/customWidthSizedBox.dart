import 'package:flutter/material.dart';

Widget customWidthSizedBox(BuildContext context, {double? widthFactor, }) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * widthFactor!,
  );
}

