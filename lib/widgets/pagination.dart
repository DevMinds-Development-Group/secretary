import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Pagination extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final List<int> availableItemsPerPage;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int>? onItemsPerPageChanged;
  const Pagination({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.onItemsPerPageChanged,
    this.itemsPerPage = 10,
    this.availableItemsPerPage = const [10, 25, 50, 100],
  }) : super(key: key);

  @override
  State<Pagination> createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  late TextEditingController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController();
    // Sincroniza el texto con la página actual (+1 para mostrar al usuario)
    _pageController.text = (widget.currentPage + 1).toString();
  }

  @override
  void didUpdateWidget(Pagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si la página actual cambia desde fuera, actualiza el campo de texto
    if (widget.currentPage != oldWidget.currentPage) {
      _pageController.text = (widget.currentPage + 1).toString();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage() {
    final pageNumberInput = int.tryParse(_pageController.text);
    if (pageNumberInput != null &&
        pageNumberInput >= 1 &&
        pageNumberInput <= widget.totalPages) {
      // Notifica al padre para que cambie a la página (restando 1 para que sea 0-indexed)
      widget.onPageChanged(pageNumberInput - 1);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Página inválida')));
      // Resetea el texto al valor correcto
      _pageController.text = (widget.currentPage + 1).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
      child: isMobile
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPageControls(isMobile),
                _buildPerPageDropdown(isMobile),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.onItemsPerPageChanged != null)
                  _buildPerPageDropdown(isMobile),
                const SizedBox(width: 15),
                _buildPageControls(isMobile),
                const SizedBox(width: 15),
                _buildGoToPage(isMobile),
                const SizedBox(width: 15),
                _buildGoButton(),
              ],
            ),
    );
  }

  Widget _buildPageControls(bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue[700]),
          onPressed: widget.currentPage > 0
              ? () {
                  print('--- PAGINATION WIDGET: Botón Atras presionado ---');
                  widget.onPageChanged(widget.currentPage - 1);
                }
              : null,
        ),
        Text(
          'Página ${widget.totalPages == 0 ? 0 : widget.currentPage + 1} de ${widget.totalPages}',
          style: TextStyle(
            fontSize: 16,
            //color: Colors.blue[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward, color: Colors.blue[700]),
          onPressed: widget.currentPage < widget.totalPages - 1
              ? () {
                  print(
                    '--- PAGINATION WIDGET: Botón Siguiente presionado ---',
                  );
                  widget.onPageChanged(widget.currentPage + 1);
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildGoToPage(bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Ir a página:',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 35,
          width: 50,
          child: TextFormField(
            controller: _pageController,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 2.0),
              border: OutlineInputBorder(),
            ),
            onFieldSubmitted: (value) => _goToPage(),
          ),
        ),
      ],
    );
  }

  Widget _buildPerPageDropdown(isMobile) {
    final int safeValue =
        widget.availableItemsPerPage.contains(widget.itemsPerPage)
        ? widget.itemsPerPage
        : widget.availableItemsPerPage.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (!isMobile)
          Text(
            'Elementos por página:',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        const SizedBox(width: 10),
        DropdownButton<int>(
          value: safeValue,
          onChanged: (value) {
            if (value != null && widget.onItemsPerPageChanged != null) {
              widget.onItemsPerPageChanged!(value);
            }
          },
          items: widget.availableItemsPerPage.map((int item) {
            return DropdownMenuItem<int>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGoButton() {
    return SizedBox(
      height: 35,
      child: ElevatedButton(
        onPressed: _goToPage,
        child: const Text('Ir'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
    );
  }
}
