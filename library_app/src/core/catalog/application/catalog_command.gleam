import core/catalog/domain/catalog_repository

pub fn compose_create_catalog(
  create_catalog: catalog_repository.CreateCatalog,
) -> catalog_repository.CreateCatalog {
  fn(catalog) { create_catalog(catalog) }
}
