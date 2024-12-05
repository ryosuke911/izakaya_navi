  final venues = await _searchService.searchByFilters(
    keyword: _searchFilters['area'],
    genres: _selectedCategories,
    personCount: _searchFilters['persons'],
    smoking: _searchFilters['smoking'],
    hasNomihodai: _searchFilters['nomihodai'],
    hasPrivateRoom: _searchFilters['privateRoom'],
    businessHours: _searchFilters['businessHours'],
    budgetMin: _convertBudgetToInt(_searchFilters['budgetMin']),
    budgetMax: _convertBudgetToInt(_searchFilters['budgetMax']),
  ); 