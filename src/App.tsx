import { HashRouter, Route, Routes } from 'react-router-dom';
import { AuthProvider } from './lib/AuthContext';
import { ThemeProvider } from './lib/ThemeContext';
import { ProtectedRoute } from './components/ProtectedRoute';
import { Login } from './pages/Login';
import { Dashboard } from './pages/Dashboard';
import { IndiceMaestro } from './pages/IndiceMaestro';
import { HojaCliente } from './pages/HojaCliente';
import { Catalogo } from './pages/Catalogo';
import { Notas } from './pages/Notas';
import { Rendimiento } from './pages/Rendimiento';
import { FacturaCliente } from './pages/FacturaCliente';
import { FacturacionRapida } from './pages/FacturacionRapida';
import { Proveedores } from './pages/Proveedores';
import { HojaProveedor } from './pages/HojaProveedor';
import { Garantias } from './pages/Garantias';
import { Fusibleras } from './pages/Fusibleras';
import { FusibleraDetalle } from './pages/FusibleraDetalle';

function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <HashRouter>
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route element={<ProtectedRoute />}>
              <Route path="/" element={<Dashboard />} />
              <Route path="/clientes" element={<IndiceMaestro />} />
              <Route path="/clientes/:id" element={<HojaCliente />} />
              <Route path="/clientes/:id/factura" element={<FacturaCliente />} />
              <Route path="/catalogo" element={<Catalogo />} />
              <Route path="/notas" element={<Notas />} />
              <Route path="/rendimiento" element={<Rendimiento />} />
              <Route path="/facturacion" element={<FacturacionRapida />} />
              <Route path="/proveedores" element={<Proveedores />} />
              <Route path="/proveedores/:id" element={<HojaProveedor />} />
              <Route path="/garantias" element={<Garantias />} />
              <Route path="/fusibleras" element={<Fusibleras />} />
              <Route path="/fusibleras/:id" element={<FusibleraDetalle />} />
            </Route>
          </Routes>
        </HashRouter>
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;
