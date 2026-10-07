import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_validators.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/masjid_request_form_fields.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/widgets/form_section.dart';
import 'package:masjid_core_frontend/shared/constants/indian_states.dart';
import 'package:masjid_core_frontend/shared/widgets/app_country_dropdown.dart';
import 'package:masjid_core_frontend/shared/widgets/app_phone_field.dart';
import 'package:masjid_core_frontend/shared/widgets/app_text_field.dart';

/// Masjid name, location and optional contact / welcome text.
class MasjidDetailsSection extends StatelessWidget {
  const MasjidDetailsSection({
    super.key,
    required this.fields,
    required this.onChanged,
  });

  final MasjidRequestFormFields fields;

  /// Called after a change that alters which fields are shown.
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final isIndia = fields.isIndia;
    return FormSection(
      title: 'Masjid Details',
      children: <Widget>[
        AppTextField(
          controller: fields.masjidName,
          label: 'Masjid Name *',
          textInputAction: TextInputAction.next,
          validator: (value) =>
              MasjidRequestValidators.required(value, 'Masjid name'),
        ),
        AppCountryDropdown(
          value: fields.masjidCountry,
          onChanged: (country) {
            fields.changeMasjidCountry(country);
            onChanged();
          },
        ),
        if (isIndia)
          DropdownButtonFormField<String>(
            // Rebuilt with the country so a cleared state shows empty.
            key: ValueKey<String>('state-${fields.masjidCountry.isoCode}'),
            initialValue: fields.state.text.isEmpty ? null : fields.state.text,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'State *',
              border: OutlineInputBorder(),
            ),
            items: indianStates
                .map(
                  (state) => DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  ),
                )
                .toList(),
            onChanged: (state) {
              fields.state.text = state ?? '';
              onChanged();
            },
            validator: (value) =>
                MasjidRequestValidators.required(value, 'State'),
          )
        else
          AppTextField(
            controller: fields.state,
            label: 'State / Province / Region *',
            textInputAction: TextInputAction.next,
            validator: (value) =>
                MasjidRequestValidators.required(value, 'State'),
          ),
        if (isIndia)
          AppTextField(
            controller: fields.district,
            label: 'District *',
            textInputAction: TextInputAction.next,
            validator: (value) =>
                MasjidRequestValidators.required(value, 'District'),
          ),
        AppTextField(
          controller: fields.locality,
          label: 'City / Village / Town *',
          textInputAction: TextInputAction.next,
          validator: (value) =>
              MasjidRequestValidators.required(value, 'City / Village / Town'),
        ),
        AppTextField(
          controller: fields.address,
          label: 'Address *',
          maxLines: 2,
          textInputAction: TextInputAction.newline,
          validator: (value) =>
              MasjidRequestValidators.required(value, 'Address'),
        ),
        AppPhoneField(
          phoneController: fields.contactNo,
          initialCountry: fields.contactCountry,
          onCountryChanged: (country) => fields.contactCountry = country,
          label: 'Phone Number',
          textInputAction: TextInputAction.next,
        ),
        AppTextField(
          controller: fields.welcomeMsg,
          label: 'Welcome Message',
          maxLines: 2,
          textInputAction: TextInputAction.newline,
        ),
        AppTextField(
          controller: fields.description,
          label: 'Description',
          maxLines: 3,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }
}
