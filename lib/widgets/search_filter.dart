  void _updateFilters() {
    widget.onFilterChanged({
      'area': _areaController.text,
      'persons': _selectedPersons,
      'smoking': _smokingStatus,
      'nomihodai': _hasNomihodai,
      'privateRoom': _hasPrivateRoom,
      'businessHours': _businessHours,
      'budgetMin': _budgetRange.start,
      'budgetMax': _budgetRange.end,
    });
  } 