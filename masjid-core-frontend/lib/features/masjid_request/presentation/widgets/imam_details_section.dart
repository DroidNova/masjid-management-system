import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_validators.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/masjid_request_form_fields.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/widgets/form_section.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/widgets/person_fields.dart';
import 'package:masjid_core_frontend/shared/widgets/app_phone_field.dart';
import 'package:masjid_core_frontend/shared/widgets/app_text_field.dart';

class ImamDetailsSection extends StatelessWidget {
  const ImamDetailsSection({
    super.key,
    required this.fields,
    required this.onChanged,
  });

  final MasjidRequestFormFields fields;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: 'Imam Details',
      children: <Widget>[
        AppTextField(
          controller: fields.imamName,
          label: 'Imam Name *',
          textInputAction: TextInputAction.next,
          validator: (value) =>
              MasjidRequestValidators.required(value, 'Imam name'),
        ),
        AppPhoneField(
          phoneController: fields.imamPhone,
          initialCountry: fields.imamCountry,
          onCountryChanged: (country) => fields.imamCountry = country,
          label: 'Imam Mobile Number *',
          isRequired: true,
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          controller: fields.imamEmail,
          label: 'Imam Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) =>
              MasjidRequestValidators.email(value, 'imam email'),
        ),
        AppTextField(
          controller: fields.imamFatherName,
          label: 'Imam Father Name *',
          textInputAction: TextInputAction.next,
          validator: (value) =>
              MasjidRequestValidators.required(value, 'Imam father name'),
        ),
        AgeField(
          controller: fields.imamAge,
          label: 'Imam Age *',
          validator: (value) => MasjidRequestValidators.age(value, 'Imam age'),
        ),
        GenderField(
          value: fields.imamGender,
          label: 'Imam Gender *',
          requiredMessage: 'Imam gender is required.',
          onChanged: (value) {
            fields.imamGender = value;
            onChanged();
          },
        ),
        AppTextField(
          controller: fields.imamAddress,
          label: 'Imam Address *',
          maxLines: 2,
          textInputAction: TextInputAction.newline,
          validator: (value) =>
              MasjidRequestValidators.required(value, 'Imam address'),
        ),
      ],
    );
  }
}
