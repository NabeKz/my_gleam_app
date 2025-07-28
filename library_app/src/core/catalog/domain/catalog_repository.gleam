import core/catalog/domain/catalog

pub type CatalogRepository {
  CatalogRepository(
    create: CreateCatalog,
    read: fn() -> catalog.Catalog,
    update: fn() -> catalog.Catalog,
    delete: fn() -> catalog.Catalog,
  )
}

pub type CreateCatalog =
  fn(catalog.Catalog) -> Result(Nil, List(String))

pub type GetCatalog =
  fn() -> Result(catalog.Catalog, List(String))
