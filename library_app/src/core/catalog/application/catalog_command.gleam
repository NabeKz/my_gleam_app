import core/catalog/domain/catalog_repository

pub fn compose_create_catalog(
  repository: catalog_repository.CatalogRepository,
) -> catalog_repository.CreateCatalog {
  fn(catalog) { repository.create(catalog) }
}
