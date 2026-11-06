# frozen_string_literal: true

class AddRegistrationCountryToNotices < ActiveRecord::Migration[8.1]
  COUNTRY_CODES = %w[
    AD AE AF AG AI AL AM AO AQ AR AS AT AU AW AX AZ
    BA BB BD BE BF BG BH BI BJ BL BM BN BO BQ BR BS BT BV BW BY BZ
    CA CC CD CF CG CH CI CK CL CM CN CO CR CU CV CW CX CY CZ
    DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ FK FM FO FR
    GA GB GD GE GF GG GH GI GL GM GN GP GQ GR GS GT GU GW GY
    HK HM HN HR HT HU ID IE IL IM IN IO IQ IR IS IT JE JM JO JP
    KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY
    MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ
    NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY
    QA RE RO RS RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR SS ST SV SX SY SZ
    TC TD TF TG TH TJ TK TL TM TN TO TR TT TV TW TZ UA UG UM US UY UZ
    VA VC VE VG VI VN VU WF WS XK YE YT ZA ZM ZW
  ].freeze

  def up
    add_column :notices, :registration_country, :string, limit: 2, default: "DE", null: false
    countries = COUNTRY_CODES.map { |code| connection.quote(code) }.join(", ")
    execute <<~SQL
      WITH tagged AS (
        SELECT id, upper(substring(registration FROM '^\\s*\\(([A-Za-z]{2})\\)\\s+.+$')) AS country
        FROM notices WHERE registration ~ '^\\s*\\([A-Za-z]{2}\\)\\s+'
      )
      UPDATE notices SET registration_country = tagged.country
      FROM tagged WHERE notices.id = tagged.id AND tagged.country IN (#{countries})
    SQL
  end

  def down
    execute <<~SQL
      UPDATE notices SET registration = '(' || registration_country || ') ' || COALESCE(registration, '')
      WHERE registration_country <> 'DE'
      AND upper(substring(registration FROM '^\\s*\\(([A-Za-z]{2})\\)\\s+.+$')) IS DISTINCT FROM registration_country
    SQL
    remove_column :notices, :registration_country
  end
end
