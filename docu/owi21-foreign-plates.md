# Foreign plates in OWI21 exports

Registrations can include an ISO alpha-2 country tag, for example `(PL) PL-A 1233` or `(FR) AB-123-CD`. The stored registration is unchanged. During OWI21 export, the tag becomes country metadata and the remaining plate is preserved, including punctuation, case, trailing letters and non-Latin characters.

The export uses three xOWi 1.1 attributes:

- `KFZ_Kennzeichen`: the plate without the country tag.
- `KFZ_Kennzeichen_Nation`: the international vehicle-country sign, such as `F` for ISO `FR`, `A` for `AT`, or `UK` for `GB`.
- `KFZ_Kennzeichen_Merkmal`: `2` for Austria, `3` for the Netherlands, `5` for Switzerland, and `6` for France. Other foreign vehicle-country signs are used directly, including `B`, `PL` and `RO`, as described by the value list's general country-sign entry.

Country-code conversions are defined in `Owi21Registration::NATION_CODES`; codes without a conversion are retained. A US country tag uses `USA`, not the separate `4` category for US civilian vehicles with German-style plates.

Unprefixed registrations and explicit `(DE)` registrations retain German normalization and plate type `1`. German exports do not gain an additional Nation attribute. `Vehicle.normalize` remains unchanged for other callers.

## Sources

- [Bundled ekom21 plate-type value list](xowi_ekom21_owi21/xOWi_Bestand_Schnittstellenbeschreibung_V1.1_Wertelisten_Schemas/Werteliste%20Kennzeichen_Merkmal_Halteranfragen.pdf), pages 1-2.
- [Bundled xOWi 1.1 interface description](xowi_ekom21_owi21/xOWi_Bestand_Schnittstellenbeschreibung_V1.1_Wertelisten_Schemas/xOWi_Bestand_Schnittstellenbeschreibung_V1.1.pdf), vehicle attributes, and the accompanying schema. The Nation attribute uses vehicle-country signs rather than ISO codes.
- [International vehicle-country signs](https://en.wikipedia.org/wiki/International_vehicle_registration_code).
- [GOV.UK: number-plate identifiers and stickers](https://www.gov.uk/displaying-number-plates/flags-identifiers-and-stickers), documenting the replacement of `GB` stickers with `UK`.
