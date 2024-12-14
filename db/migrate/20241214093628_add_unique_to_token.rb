class AddUniqueToToken < ActiveRecord::Migration[7.1]
  def change
    remove_index(:brands, :token)
    add_index(:brands, :token, unique: true)

    add_column(:brands, :share, :decimal)

    reversible do |dir|
      dir.up do
        {
        "Volkswagen" => [10_039_389, 21.3],
        "Opel" => [4_455_662, 9.5],
        "Mercedes-Benz" => [4_434_329, 9.4],
        "Ford" => [3_438_207, 7.3],
        "Audi" => [3_242_838, 6.9],
        "BMW" => [3_256_884, 6.9],
        "Škoda" => [2_169_706, 4.6],
        "Renault" => [1_773_013, 3.8],
        "Toyota" => [1_302_395, 2.8],
        "Fiat" => [1_174_960, 2.5],
        "Hyundai" => [1_195_023, 2.5],
        "Seat" => [1_154_612, 2.5],
        "Peugeot" => [1_119_914, 2.4],
        "Mazda" => [859_054, 1.8],
        "Nissan" => [863_144, 1.8],
        "Citroën" => [742_167, 1.6],
        "Kia" => [662_174, 1.4],
        "Dacia" => [547_617, 1.2],
        "Suzuki" => [502_393, 1.1],
        "Honda" => [451_525, 1.0],
        "Mitsubishi" => [484_017, 1.0],
        "Smart" => [474_898, 1.0],
        "Volvo" => [489_040, 1.0],
        "MINI" => [445_226, 0.9],
        "Porsche" => [313_173, 0.7],
        "Chevrolet" => [214_604, 0.5],
        "Alfa Romeo" => [119_095, 0.3],
        "Subaru" => [123_887, 0.3],
        "Daihatsu" => [78_619, 0.2],
        "Jaguar" => [73_932, 0.2],
        "Jeep" => [112_467, 0.2],
        "Land Rover" => [108_056, 0.2],
        "Chrysler" => [59_001, 0.1],
        "DS Automobiles" => [33_607, 0.1],
        "Lancia" => [28_860, 0.1],
        "Lexus" => [27_282, 0.1],
        "MG" => [28_777, 0.1],
        "Saab" => [44_345, 0.1],
      }.each do |name, (num, share)|
          brand = Brand.find_by(name: name)
          next unless brand
          Rails.logger.info("Updating share for #{brand.name} to #{share}")
          brand.update_column(:share, share)
        end
      end
    end
  end
end
