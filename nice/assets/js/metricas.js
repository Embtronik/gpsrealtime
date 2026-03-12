/**
 * metricas.js — Métricas de servicios por período con ApexCharts
 * Gráfica de líneas (comparativo mensual) + tortas (distribución por tipo)
 */

'use strict';

// ── Instancias de gráficas ────────────────────────────────────────
let lineChartInst  = null;
let pieChartAInst  = null;
let pieChartBInst  = null;

const COLORS = [
  '#4154f1','#2eca6a','#ff771d','#e74c3c','#9b59b6','#1abc9c','#f39c12','#2980b9'
];

const MESES = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];

// ── Inicializar fechas por defecto (año anterior vs año actual) ───
(function initFechas() {
  const hoy   = new Date();
  const anioA = hoy.getFullYear() - 1;
  const anioB = hoy.getFullYear();

  document.getElementById('fechaDesdeA').value = `${anioA}-01-01`;
  document.getElementById('fechaHastaA').value = `${anioA}-12-31`;
  document.getElementById('fechaDesdeB').value = `${anioB}-01-01`;
  document.getElementById('fechaHastaB').value = `${String(anioB)}-${String(hoy.getMonth()+1).padStart(2,'0')}-${String(hoy.getDate()).padStart(2,'0')}`;
})();

// ── Evento principal ──────────────────────────────────────────────
document.getElementById('btnConsultar').addEventListener('click', async () => {
  const fechaDesdeA = document.getElementById('fechaDesdeA').value;
  const fechaHastaA = document.getElementById('fechaHastaA').value;
  const fechaDesdeB = document.getElementById('fechaDesdeB').value;
  const fechaHastaB = document.getElementById('fechaHastaB').value;

  if (!fechaDesdeA || !fechaHastaA || !fechaDesdeB || !fechaHastaB) {
    alert('Complete los cuatro rangos de fecha.');
    return;
  }

  setLoading(true);
  document.getElementById('sinDatos').classList.add('d-none');

  try {
    const [resA, resB] = await Promise.all([
      fetchMetricas(fechaDesdeA, fechaHastaA),
      fetchMetricas(fechaDesdeB, fechaHastaB)
    ]);

    if (!resA.success || !resB.success) {
      alert('Error al obtener datos: ' + (resA.message || resB.message));
      return;
    }

    if (resA.data.length === 0 && resB.data.length === 0) {
      document.getElementById('sinDatos').classList.remove('d-none');
      destroyCharts();
      return;
    }

    const labelA = `${fechaDesdeA} / ${fechaHastaA}`;
    const labelB = `${fechaDesdeB} / ${fechaHastaB}`;

    renderLineChart(resA.data, resB.data, labelA, labelB);
    renderPieChart(resA.data, 'pieChartA', 'pieSubtitleA', labelA);
    renderPieChart(resB.data, 'pieChartB', 'pieSubtitleB', labelB);
    renderTabla(resA.data, resB.data, labelA, labelB);

  } catch (err) {
    alert('Error de conexión: ' + err.message);
  } finally {
    setLoading(false);
  }
});

// ── Fetch ─────────────────────────────────────────────────────────
async function fetchMetricas(fechaDesde, fechaHasta) {
  const resp = await fetch('../codigo/apiMetricas.php', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ fechaDesde, fechaHasta })
  });
  return resp.json();
}

// ── Gráfica de líneas ─────────────────────────────────────────────
function renderLineChart(dataA, dataB, labelA, labelB) {
  // Armar series: una por tipo de servicio por período
  const tiposA = agruparPorTipoMes(dataA);  // { tipo: { mes: total } }
  const tiposB = agruparPorTipoMes(dataB);
  const todosTipos = [...new Set([...Object.keys(tiposA), ...Object.keys(tiposB)])].sort();

  const series = [];
  todosTipos.forEach((tipo, i) => {
    if (tiposA[tipo]) {
      series.push({
        name: `${tipo} (${labelA})`,
        data: MESES.map((_, m) => tiposA[tipo][m+1] || 0),
        color: COLORS[i % COLORS.length]
      });
    }
    if (tiposB[tipo]) {
      series.push({
        name: `${tipo} (${labelB})`,
        data: MESES.map((_, m) => tiposB[tipo][m+1] || 0),
        color: COLORS[i % COLORS.length],
        dashArray: 5
      });
    }
  });

  if (lineChartInst) { lineChartInst.destroy(); }

  lineChartInst = new ApexCharts(document.getElementById('lineChart'), {
    series,
    chart: { type: 'line', height: 380, toolbar: { show: true } },
    stroke: { curve: 'smooth', width: 2, dashArray: series.map(s => s.dashArray || 0) },
    xaxis: { categories: MESES, title: { text: 'Mes' } },
    yaxis: { title: { text: 'Servicios' }, min: 0, forceNiceScale: true },
    tooltip: { shared: true, intersect: false },
    legend: { position: 'bottom' },
    markers: { size: 4 }
  });
  lineChartInst.render();

  document.getElementById('lineSubtitle').textContent = `(${labelA}  vs  ${labelB})`;
}

// ── Gráfica de torta ──────────────────────────────────────────────
function renderPieChart(data, containerId, subtitleId, label) {
  const totalesPorTipo = {};
  data.forEach(r => {
    totalesPorTipo[r.tipoServicio] = (totalesPorTipo[r.tipoServicio] || 0) + parseInt(r.total, 10);
  });

  const labels  = Object.keys(totalesPorTipo);
  const valores = Object.values(totalesPorTipo);

  const inst = containerId === 'pieChartA' ? pieChartAInst : pieChartBInst;
  if (inst) { inst.destroy(); }

  const chart = new ApexCharts(document.getElementById(containerId), {
    series: valores,
    labels,
    chart: { type: 'pie', height: 340 },
    colors: COLORS,
    legend: { position: 'bottom' },
    tooltip: { y: { formatter: v => `${v} servicios` } }
  });
  chart.render();

  if (containerId === 'pieChartA') { pieChartAInst = chart; }
  else                              { pieChartBInst = chart; }

  document.getElementById(subtitleId).textContent = `(${label})`;
}

// ── Tabla resumen ─────────────────────────────────────────────────
function renderTabla(dataA, dataB, labelA, labelB) {
  const totA = sumarPorTipo(dataA);
  const totB = sumarPorTipo(dataB);
  const tipos = [...new Set([...Object.keys(totA), ...Object.keys(totB)])].sort();

  document.getElementById('colPeriodoA').textContent = labelA;
  document.getElementById('colPeriodoB').textContent = labelB;

  const tbody = document.getElementById('tbodyResumen');
  tbody.innerHTML = tipos.map(tipo => {
    const a   = totA[tipo] || 0;
    const b   = totB[tipo] || 0;
    const dif = b - a;
    const badge = dif > 0
      ? `<span class="badge bg-success">+${dif}</span>`
      : dif < 0
        ? `<span class="badge bg-danger">${dif}</span>`
        : `<span class="badge bg-secondary">0</span>`;
    return `<tr>
      <td>${tipo}</td>
      <td class="text-center">${a}</td>
      <td class="text-center">${b}</td>
      <td class="text-center">${badge}</td>
    </tr>`;
  }).join('');

  // Fila totales
  const totalA = Object.values(totA).reduce((s,v) => s+v, 0);
  const totalB = Object.values(totB).reduce((s,v) => s+v, 0);
  const difTotal = totalB - totalA;
  const badgeTotal = difTotal > 0
    ? `<span class="badge bg-success">+${difTotal}</span>`
    : difTotal < 0
      ? `<span class="badge bg-danger">${difTotal}</span>`
      : `<span class="badge bg-secondary">0</span>`;
  tbody.innerHTML += `<tr class="fw-bold table-light">
    <td>TOTAL</td>
    <td class="text-center">${totalA}</td>
    <td class="text-center">${totalB}</td>
    <td class="text-center">${badgeTotal}</td>
  </tr>`;
}

// ── Helpers ───────────────────────────────────────────────────────
function agruparPorTipoMes(data) {
  // { tipoServicio: { 1: total, 2: total, ... } }
  const result = {};
  data.forEach(r => {
    if (!result[r.tipoServicio]) result[r.tipoServicio] = {};
    result[r.tipoServicio][parseInt(r.mes)] = parseInt(r.total, 10);
  });
  return result;
}

function sumarPorTipo(data) {
  const result = {};
  data.forEach(r => {
    result[r.tipoServicio] = (result[r.tipoServicio] || 0) + parseInt(r.total, 10);
  });
  return result;
}

function destroyCharts() {
  if (lineChartInst) { lineChartInst.destroy(); lineChartInst = null; }
  if (pieChartAInst) { pieChartAInst.destroy(); pieChartAInst = null; }
  if (pieChartBInst) { pieChartBInst.destroy(); pieChartBInst = null; }
  document.getElementById('tbodyResumen').innerHTML =
    '<tr><td colspan="4" class="text-center text-muted">Sin datos para el rango seleccionado.</td></tr>';
}

function setLoading(state) {
  document.getElementById('loadingSpinner').classList.toggle('d-none', !state);
  document.getElementById('btnConsultar').disabled = state;
}
