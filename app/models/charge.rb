class Charge < ActiveRecord::Base
  validates :tbnr, :description, presence: true
  validates :tbnr, length: {is: 6}

  has_many :charge_variants, foreign_key: :table_id, primary_key: :variant_table_id

  scope :active, -> { where(classification: 5, valid_to: nil) }

  # classification
  # Schluessel,Bezeichnung,Laenge,Genauigkeit
  # '0','sonstige','',''
  # '1','Lichtzeichen','',''
  # '2','Behinderung','',''
  # '3','Gefährdung','',''
  # '4','Unfall','',''
  # '5','Halt- und Parkverstoß','',''
  # '6','Geschwindigkeitsüberschreitung','3','0'
  # '7','Überladung','',''
  # '8','Alkohol und Rauschmittel','',''
  # '9','Abstandsmessung','',''
  # 'M','Messangabe','',''

  FAP = {
    'A' => 'schwerwiegende Zuwiderhandlung',
    'B' => 'weniger schwerwiegende Zuwiderhandlung',
  }

  def fap_description
    FAP[fap] || '-'
  end
end
