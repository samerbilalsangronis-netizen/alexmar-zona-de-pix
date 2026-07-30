import { HashRouter, Route, Routes } from 'react-router-dom';
import { AuthProvider } from './lib/AuthContext';
import { ProtectedRoute } from './components/ProtectedRoute';
import { Login } from './pages/Login';
import { Dashboard } from './pages/Dashboard';
import { IndiceMaestro } from './pages/IndiceMaestro';
import { HojaCliente } from './pages/HojaCliente';
import { Catalogo } from './pages/Catalogo';
import { Notas } from './pages/Notas';
import { Rendimiento } from './pages/Rendimiento';

function App() {
  return (
    <AuthProvider>
      <HashRouter>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route element={<ProtectedRoute />}>
            <Route path="/" element={<Dashboard />} />
            <Route path="/clientes" element={<IndiceMaestro />} />
            <Route path="/clientes/:id" element={<HojaCliente />} />
            <Route path="/catalogo" element={<Catalogo />} />
            <Route path="/notas" element={<Notas />} />
            <Route path="/rendimiento" element={<Rendimiento />} />
          </Route>
        </Routes>
      </HashRouter>
    </AuthProvider>
  );
}

export default App;
