import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_validators.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/masjid_request_form_fields.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/widgets/form_section.dart';
import 'package:masjid_core_frontend/shared/widgets/app_phone_field.dart';
import 'package:masjid_core_frontend/shared/widgets/app_text_field.dart';

/// Who is asking: name, mobile (used to track the application), email.
class RequesterDetailsSection extends StatelessWidget {
  const RequesterDetailsSection({super.key, required this.fields});

  final MasjidRequestFormFields fields;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: 'Requester Details',
      children: <Widget>[
        AppTextField(
          controller: fields.requesterName,
          label: 'Requester Name *',
          textInputAction: TextInputAction.next,
          validator: (value) =>
              MasjidRequestValidators.required(value, 'Your name'),
        ),
        AppPhoneField(
          phoneController: fields.requesterPhone,
          initialCountry: fields.requesterCountry,
          onCountryChanged: (country) => fields.requesterCountry = country,
          label: 'Requester Mobile Number *',
          isRequired: true,
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          controller: fields.requesterEmail,
          label: 'Requester Email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) =>
              MasjidRequestValidators.email(value, 'email address'),
        ),
      ],
    );
  }
}
