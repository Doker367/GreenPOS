/// GraphQL Operations for Invoice/CFDI feature
/// These queries and mutations match the backend schema

/// Create a new invoice (DRAFT status)
const String createInvoice = r'''
  mutation CreateInvoice($input: CreateInvoiceInput!) {
    createInvoice(input: $input) {
      id
      status
      serie
      folio
      uuid
      total
    }
  }
''';

/// Stamp/emit an invoice (DRAFT -> TIMBRADA)
const String stampInvoice = r'''
  mutation StampInvoice($id: UUID!) {
    stampInvoice(id: $id) {
      id
      status
      uuid
      pdfUrl
      xmlUrl
    }
  }
''';

/// Cancel an invoice
const String cancelInvoice = r'''
  mutation CancelInvoice($id: UUID!, $motivo: String!) {
    cancelInvoice(id: $id, motivo: $motivo) {
      id
      status
    }
  }
''';

/// Get invoices for a branch with optional status filter
const String getInvoices = r'''
  query GetInvoices($branchId: UUID!, $status: InvoiceStatus) {
    invoices(branchId: $branchId, status: $status) {
      id
      serie
      folio
      uuid
      status
      receptorRfc
      receptorNombre
      total
      createdAt
    }
  }
''';

/// Get a single invoice by ID with full details
const String getInvoice = r'''
  query GetInvoice($id: UUID!) {
    invoice(id: $id) {
      id
      serie
      folio
      uuid
      status
      emisorRfc
      emisorNombre
      emisorRegimen
      receptorRfc
      receptorNombre
      receptorUsoCfdi
      receptorDomicilio
      formaPago
      metodoPago
      subtotal
      descuento
      impuestosTrasladados
      total
      iva16Amount
      iepsAmount
      pdfUrl
      xmlUrl
      items {
        id
        productName
        claveProdServ
        claveUnidad
        quantity
        unitPrice
        discount
        taxRate
        taxAmount
        total
      }
      createdAt
    }
  }
''';

/// Get tenant fiscal configuration
const String getTenantFiscal = r'''
  query GetTenantFiscal {
    tenantFiscal {
      id
      rfc
      razonSocial
      regimenFiscal
      calle
      numero
      colonia
      cp
      ciudad
      estado
      pais
    }
  }
''';

/// Update tenant fiscal configuration
const String updateTenantFiscal = r'''
  mutation UpdateTenantFiscal($input: UpdateTenantFiscalInput!) {
    updateTenantFiscal(input: $input) {
      id
      rfc
      razonSocial
      regimenFiscal
    }
  }
''';

/// Create tenant fiscal configuration
const String createTenantFiscal = r'''
  mutation CreateTenantFiscal($input: UpdateTenantFiscalInput!) {
    createTenantFiscal(input: $input) {
      id
      rfc
      razonSocial
      regimenFiscal
    }
  }
''';
