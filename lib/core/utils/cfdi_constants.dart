/// CFDI Constants for Mexican Invoice (Factura Electrónica)
///
/// These constants follow SAT (Servicio de Administración Tributaria) standards

class CFDIConstants {
  CFDIConstants._();

  // ===== FORMA DE PAGO =====
  /// How the payment was made
  static const Map<String, String> formaPago = {
    '01': 'Efectivo',
    '02': 'Cheque nominativo',
    '03': 'Transferencia electrónica de fondos',
    '04': 'Tarjeta de crédito',
    '05': 'Monedero electrónico',
    '06': 'Dinero electrónico',
    '08': 'Vales de despensa',
    '28': 'Monedero electrónico',
    '99': 'Por definir',
  };

  // ===== MÉTODO DE PAGO =====
  /// Payment method
  static const Map<String, String> metodoPago = {
    'PUE': 'Pago en una exhibición',
    'PPD': 'Pago en parcialidades o diferido',
  };

  // ===== USO CFDI =====
  /// CFDI use - what the receiver will do with the invoice
  static const Map<String, String> usoCfdi = {
    'G01': 'Gastos en general',
    'G02': 'Público en general',
    'G03': 'Nómina',
    'D01': 'Donativos',
    'I01': 'Construcciones',
    'I02': 'Mobilario y equipo de oficina por inversiones',
    'I03': 'Equipo de transporte',
    'I04': 'Equipo de cómputo y accesorios',
    'I05': 'Dados, troqueles, moldes, matrices y herramental',
    'I06': 'Comunicaciones telefónicas',
    'I07': 'Comunicaciones satelitales',
    'I08': 'Otra maquinaria y equipo',
    'D02': 'Transformadores eléctricos y aparamenta',
    'D03': 'Equipo de generación de energía',
    'D04': 'Pzas.accessorias equipo.de.transporte',
    'D05': 'Pzas.accessorias maquinaria y equipo',
    'D06': 'Otros equipos',
    'D07': 'Habitación',
    'D08': 'Transporte de bienes personal o del hogar',
    'D09': 'Educación',
    'D10': 'Representación',
    'I01': 'Nómina',
    'S01': 'Sin efectos fiscales',
    'CP01': 'Nómina',
  };

  // ===== RÉGIMEN FISCAL =====
  /// Tax regime types
  static const Map<String, String> regimenFiscal = {
    '601': 'General de Ley Personas Morales',
    '603': 'Personas Morales con fines no lucrativos',
    '605': 'Sueldos y salarios e ingresos asimilados a salarios',
    '606': 'Arrendamiento',
    '607': 'Régimen de enajenación o adquisición de bienes',
    '608': 'Demas ingresos',
    '609': 'Consolidación',
    '610': 'Residentes en el extranjero',
    '611': 'Ingresos por Dividendos (personas físicas)',
    '612': 'Personas físicas con ingresos distintos a honorarios',
    '614': 'Ingresos por intereses',
    '615': 'Régimen de los ingresos por ganar',
    '616': 'Sin obligaciones fiscales',
    '620': 'Sociedades Cooperativas de Producción',
    '621': 'Régimen Simplificado Confiable',
    '622': 'Actividades Agrícolas, Ganaderas, Silvícolas y Pesqueras',
    '623': 'Opcional para Grupos de Sociedades',
    '624': 'Coordinados',
    '625': 'Régimen de las Personas Físicas con Actividades Empresariales',
    '626': 'Incorporación Fiscal',
  };

  // ===== CLAVE PRODUCTO/SERVICIO (SAT) =====
  /// SAT product/service classification codes - Common restaurant items
  static const Map<String, String> claveProdServ = {
    '50201700': 'Bebidas no alcohólicas',
    '50201701': 'Bebidas energéticas no alcohólicas',
    '50201702': 'Bebidas isotónicas no alcohólicas',
    '50201703': 'Agua embotellada',
    '50201704': 'Bebidas carbonatadas no alcohólicas',
    '50201705': 'Jugos y néctares de frutas o verduras',
    '50201706': 'Bebidas a base de café',
    '50201707': 'Bebidas a base de té',
    '50201708': 'Bebida de soya',
    '50201709': ' Otras bebidas no alcohólicas',
    '50201800': 'Bebidas calientes (café, té, chocolate, etc.)',
    '50201801': 'Café',
    '50201802': 'Chocolate',
    '50201803': 'Té',
    '50211500': 'Alimentos preparados',
    '50211501': 'Alimentos preparados en establecimiento',
    '50211502': 'Alimentos para llevar',
    '50211503': 'Servicio de catering',
    '50211504': 'Comida rápida',
    '50211505': 'Alimentos para mascotas',
    '50211600': 'Alimentos diversos',
    '50211601': 'Botanas y botanas半夜',
    '50211602': 'Frutos secos',
    '50211603': 'Dulces y golosinas',
    '50211604': 'Helados y nieves',
    '90101600': 'Servicios de restaurant',
    '90101601': 'Servicios de restaurant-bar',
    '90101602': 'Servicios de cafeteria',
    '90101603': 'Servicios de comida rápida',
    '90101604': 'Servicios de catering',
    '90101700': 'Servicios de preparación de alimentos',
    '90101701': 'Servicio de banquetes',
    '90101702': 'Servicio de coffee break',
  };

  // ===== CLAVE UNIDAD (SAT) =====
  /// SAT unit classification codes
  static const Map<String, String> claveUnidad = {
    'E48': 'Unidad de servicio',
    'H87': 'Pieza',
    'KGM': 'Kilogramo',
    'GRM': 'Gramo',
    'LTR': 'Litro',
    'MLT': 'Mililitro',
    'MTR': 'Metro',
    'MTK': 'Metro cuadrado',
    'MTQ': 'Metro cúbico',
    'PAQ': 'Paquete',
    'BUL': 'Barril',
    'GAL': 'Galón',
    'LT': 'Litro',
    'KG': 'Kilogramo',
    'G': 'Gramo',
    'PZ': 'Pieza',
    'SERV': 'Servicio',
  };

  // ===== STATUS DISPLAY NAMES =====
  static const Map<String, String> invoiceStatusNames = {
    'DRAFT': 'Borrador',
    'PENDING': 'Pendiente',
    'TIMBRADA': 'Timbrada',
    'CANCELLED': 'Cancelada',
  };

  // ===== DEFAULT VALUES =====
  static const String defaultFormaPago = '01';
  static const String defaultMetodoPago = 'PUE';
  static const String defaultUsoCfdi = 'G01';
  static const String defaultRegimenFiscal = '601';
  static const String defaultClaveProdServ = '90101600';
  static const String defaultClaveUnidad = 'E48';
}
