class CarData {
  static const Map<String, List<String>> makesAndModels = {
    'Toyota': [
      'Corolla',
      'Camry',
      'Hilux',
      'RAV4',
      'Land Cruiser',
      'Yaris',
      'Prius',
      'C-HR',
      'Fortuner'
    ],
    'Hyundai': [
      'Elantra',
      'Sonata',
      'Tucson',
      'Santa Fe',
      'Accent',
      'i10',
      'i20',
      'i30',
      'Kona',
      'Venue'
    ],
    'Kia': [
      'Picanto',
      'Rio',
      'Cerato',
      'Sportage',
      'Sorento',
      'Optima',
      'K5',
      'Soul',
      'Seltos'
    ],
    'Mercedes': [
      'C-Class',
      'E-Class',
      'S-Class',
      'G-Class',
      'GLA',
      'GLC',
      'GLE',
      'A-Class',
      'CLA'
    ],
    'BMW': [
      '3 Series',
      '5 Series',
      '7 Series',
      'X1',
      'X3',
      'X5',
      'X6',
      'M3',
      'M5'
    ],
    'Nissan': [
      'Sunny',
      'Sentra',
      'Altima',
      'Maxima',
      'X-Trail',
      'Patrol',
      'Juke',
      'Kicks'
    ],
    'Honda': [
      'Civic',
      'Accord',
      'CR-V',
      'Pilot',
      'HR-V',
      'City',
      'Jazz'
    ],
    'Volkswagen': [
      'Golf',
      'Polo',
      'Passat',
      'Tiguan',
      'Touareg',
      'Jetta',
      'Arteon'
    ],
    'Audi': [
      'A3',
      'A4',
      'A6',
      'A8',
      'Q3',
      'Q5',
      'Q7',
      'Q8'
    ],
    'Ford': [
      'Focus',
      'Fiesta',
      'Fusion',
      'Mustang',
      'Explorer',
      'Escape',
      'Edge',
      'Ranger'
    ],
    'Chevrolet': [
      'Spark',
      'Malibu',
      'Cruze',
      'Camaro',
      'Tahoe',
      'Suburban',
      'Traverse'
    ],
    'Mazda': [
      'Mazda 3',
      'Mazda 6',
      'CX-3',
      'CX-5',
      'CX-9',
      'MX-5'
    ],
    'Skoda': [
      'Octavia',
      'Superb',
      'Fabia',
      'Kodiaq',
      'Karoq',
      'Scala'
    ],
    'Seat': [
      'Ibiza',
      'Leon',
      'Ateca',
      'Arona',
      'Tarraco'
    ],
    'Peugeot': [
      '208',
      '301',
      '3008',
      '5008',
      '508',
      '2008'
    ],
    'Renault': [
      'Clio',
      'Megane',
      'Symbol',
      'Duster',
      'Kadjar',
      'Koleos',
      'Logan'
    ],
  };

  static List<String> get makes => makesAndModels.keys.toList()..sort();

  static List<String> getModels(String make) {
    return makesAndModels[make] ?? [];
  }
}
