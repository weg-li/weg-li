# Foreign plates in OWI21 exports

Notices store `registration_country` separately from `registration`. It is an ISO alpha-2 code and defaults to Germany (`DE`) in both the database and API. For example, clients can send `{notice: {registration: "AB-123-CD", registration_country: "FR"}}`.

Legacy country tags such as `(PL) PL-A 1233` remain supported. The country is inferred and stored without changing the original registration string. The migration backfills recognized tags on existing notices; other notices default to Germany. An explicitly supplied country must agree with any tag. Updating an ordinary plate without a country keeps the current country; replacing a legacy tagged plate with untagged input returns to Germany.

During OWI21 export, the country becomes structured metadata and the plate is preserved, including punctuation, case, trailing letters and non-Latin characters. Human-readable reports include the country tag for foreign plates.

The export uses three xOWi 1.1 attributes:

- `KFZ_Kennzeichen`: the plate without the country tag.
- `KFZ_Kennzeichen_Nation`: the international vehicle-country sign, such as `F` for ISO `FR`, `A` for `AT`, or `UK` for `GB`.
- `KFZ_Kennzeichen_Merkmal`: `2` for Austria, `3` for the Netherlands, `5` for Switzerland, and `6` for France. Other foreign vehicle-country signs are used directly, including `B`, `PL` and `RO`, as described by the value list's general country-sign entry.

`config/data/vehicle_countries.json` is the shared country catalog. Each record contains the vehicle-country sign and OWI21 plate type, keyed by ISO code. `VehicleCountry` exposes immutable records with `iso_code`, `vehicle_sign` and `owi21_plate_type`. Public `GET /api/vehicle_countries` returns an array of those records, for example `{"iso_code":"DE","vehicle_sign":"D","owi21_plate_type":"1"}`. A US country uses `USA`, not the separate `4` category for US civilian vehicles with German-style plates.

Notice readback includes both `registration` and `registration_country`. Legacy strings keep their tag; structured inputs read back their unprefixed plate. Clients editing an old tagged value should remove its recognized tag before sending an explicit country, so the two inputs agree. Unrelated partial updates retain the stored country.

Deploy the registration-country migration before the updated app. Its rollback restores foreign country tags before removing the separate field.

Unprefixed registrations and explicit `(DE)` registrations retain German normalization and plate type `1`. German exports do not gain an additional Nation attribute. `Vehicle.normalize` remains unchanged for other callers.

## Sources

- [Bundled ekom21 plate-type value list](xowi_ekom21_owi21/xOWi_Bestand_Schnittstellenbeschreibung_V1.1_Wertelisten_Schemas/Werteliste%20Kennzeichen_Merkmal_Halteranfragen.pdf), pages 1-2.
- [Bundled xOWi 1.1 interface description](xowi_ekom21_owi21/xOWi_Bestand_Schnittstellenbeschreibung_V1.1_Wertelisten_Schemas/xOWi_Bestand_Schnittstellenbeschreibung_V1.1.pdf), vehicle attributes, and the accompanying schema. The Nation attribute uses vehicle-country signs rather than ISO codes.
- [International vehicle-country signs](https://en.wikipedia.org/wiki/International_vehicle_registration_code).
- [GOV.UK: number-plate identifiers and stickers](https://www.gov.uk/displaying-number-plates/flags-identifiers-and-stickers), documenting the replacement of `GB` stickers with `UK`.
