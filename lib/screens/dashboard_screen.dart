import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:metrixvox_app/config/app_config.dart';

class DashboardScreen extends StatefulWidget {
  final String tenantId;

  const DashboardScreen({super.key, required this.tenantId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final response = await http
          .get(
            Uri.parse('${AppConfig.dashboardUrl}/metrics'),
            headers: {
              "Content-Type": "application/json",
              "X-Tenant-Id": widget.tenantId,
            },
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _dashboardData = jsonDecode(utf8.decode(response.bodyBytes));
          _errorMessage = '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error al cargar métricas (Código: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error de conexión con el servidor: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MetrixVox Dashboard - ${widget.tenantId}'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              _fetchDashboardData();
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _fetchDashboardData,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      _buildGlobalScoreCard(),
                      const SizedBox(height: 16),
                      _buildSentimentBreakdownCard(),
                      const SizedBox(height: 16),
                      _buildCategoriesPerformanceCard(),
                      const SizedBox(height: 16),
                      _buildActionCenterAlertsCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildGlobalScoreCard() {
    final totalResponses = _dashboardData?['totalResponses'] ?? 0;
    final globalScore = _dashboardData?['globalScore'] ?? 0.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Índice Global MetrixVox", style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                Text("$globalScore / 5.0", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Encuestas", style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                Text("$totalResponses", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentimentBreakdownCard() {
    final sentiment = _dashboardData?['sentimentBreakdown'] ?? {};
    final int pos = sentiment['positiveCount'] ?? 0;
    final int neu = sentiment['neutralCount'] ?? 0;
    final int neg = sentiment['negativeCount'] ?? 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Análisis de Sentimiento (IA)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _sentimentBadge("Positivos", pos, Colors.green),
                _sentimentBadge("Neutros", neu, Colors.orange),
                _sentimentBadge("Negativos", neg, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sentimentBadge(String label, int count, Color color) {
    return Column(
      children: [
        Text("$count", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCategoriesPerformanceCard() {
    final categories = _dashboardData?['categoryPerformances'] as List<dynamic>? ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Rendimiento por Categoría", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            if (categories.isEmpty)
              const Text("Sin datos de categorías registrados.", style: TextStyle(color: Colors.grey))
            else
              ...categories.map((cat) {
                final name = cat['categoryName'] ?? '';
                final score = cat['averageScore'] ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 14)),
                      Text("$score / 5.0", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCenterAlertsCard() {
    final alerts = _dashboardData?['pendingAlerts'] as List<dynamic>? ?? [];

    return Card(
      elevation: 2,
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 8),
                Text("Action Center (Alertas Críticas)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const Divider(),
            if (alerts.isEmpty)
              const Text("No hay incidencias críticas pendientes de atender.", style: TextStyle(color: Colors.grey))
            else
              ...alerts.map((alert) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Categoría: ${alert['detectedCategory']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent)),
                      const SizedBox(height: 4),
                      Text('"${alert['verbatimSnippet']}"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(alert['summaryDescription'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
