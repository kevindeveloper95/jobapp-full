import { SearchResponse } from '@elastic/elasticsearch/lib/api/types';
import { elasticSearchClient } from '@gig/elasticsearch';
import { IHitsTotal, IPaginateProps,ISearchResult } from '@kevindeveloper95/jobapp-shared';

/**
 * @description Busca gigs (servicios) en Elasticsearch que pertenecen a un vendedor específico.
 * @param {string} searchQuery - El ID del vendedor para buscar.
 * @param {boolean} active - Estado de los gigs a buscar (activos o inactivos).
 * @returns {Promise<ISearchResult>} - Una promesa que resuelve a un objeto con el total de resultados y los hits de la búsqueda.
 */
const gigsSearchBySellerId = async (searchQuery: string, active: boolean): Promise<ISearchResult> => {
  const queryList: any[] = [
    {
      query_string: {
        fields: ['sellerId'],
        query: `*${searchQuery}*`
      }
    },
    {
      term: {
        active
      }
    }
  ];
  const result: SearchResponse = await elasticSearchClient.search({
    index: 'gigs',
    query: {
      bool: {
        must:  [...queryList]
      }
    }
  });
  const total: IHitsTotal = result.hits.total as IHitsTotal;
  return {
    total: total.value,
    hits: result.hits.hits
  };
};

/**
 * @description Realiza una búsqueda general de gigs con múltiples filtros y paginación.
 * @param {string} searchQuery - El término de búsqueda principal.
 * @param {IPaginateProps} paginate - Objeto con propiedades para la paginación (from, size, type).
 * @param {string} deliveryTime - Filtro opcional para el tiempo de entrega.
 * @param {number} min - Filtro opcional para el precio mínimo.
 * @param {number} max - Filtro opcional para el precio máximo.
 * @returns {Promise<ISearchResult>} - Una promesa que resuelve a un objeto con el total de resultados y los hits de la búsqueda.
 */
const gigsSearch = async (
  searchQuery: string,
  paginate: IPaginateProps,
  deliveryTime?: string,
  min?: number,
  max?: number
): Promise<ISearchResult> => {
  const { from, size, type } = paginate;
  const queryList: any[] = [
    {
      query_string: {
        fields: ['username', 'title', 'description', 'basicDescription', 'basicTitle', 'categories', 'subCategories', 'tags'],
        query: `*${searchQuery}*`
      }
    },
    {
      term: {
        active: true
      }
    }
  ];

  if (deliveryTime !== 'undefined') {
    queryList.push({
      query_string: {
        fields: ['expectedDelivery'],
        query: `*${deliveryTime}*`
      }
    });
  }

  if (!isNaN(parseInt(`${min}`)) && !isNaN(parseInt(`${max}`))) {
    queryList.push({
      range: {
        price: {
          gte: min,
          lte: max
        }
      }
    });
  }
  const result: SearchResponse = await elasticSearchClient.search({
    index: 'gigs',
    size,
    query: {
      bool: {
        must: [...queryList]
      }
    },
    sort: [
      {
        sortId: type === 'forward' ? 'asc' : 'desc'
      }
    ],
    ...(from !== '0' && { search_after: [from] })
  });
  const total: IHitsTotal = result.hits.total as IHitsTotal;
  return {
    total: total.value,
    hits: result.hits.hits
  };
};

/**
 * @description Busca gigs que coincidan con una categoría específica.
 * @param {string} searchQuery - La categoría a buscar.
 * @returns {Promise<ISearchResult>} - Una promesa que resuelve a un objeto con el total de 10 resultados y los hits de la búsqueda.
 */
const gigsSearchByCategory = async (searchQuery: string): Promise<ISearchResult> => {
  const result: SearchResponse = await elasticSearchClient.search({
    index: 'gigs',
    size: 10,
    query: {
      bool: {
        must: [
          {
            query_string: {
              fields: ['categories'],
              query: `*${searchQuery}*`
            }
          },
          {
            term: {
              active: true
            }
          }
        ]
      }
    },
  });
  const total: IHitsTotal = result.hits.total as IHitsTotal;
  return {
    total: total.value,
    hits: result.hits.hits
  };
};

/**
 * @description Encuentra gigs similares a uno existente, basado en sus campos.
 * @param {string} gigId - El ID del gig a partir del cual se encontrarán similitudes.
 * @returns {Promise<ISearchResult>} - Una promesa que resuelve a un objeto con el total de 5 resultados y los hits de la búsqueda.
 */
const getMoreGigsLikeThis = async (gigId: string): Promise<ISearchResult> => {
  const result: SearchResponse = await elasticSearchClient.search({
    index: 'gigs',
    size: 5,
    query: {
      more_like_this: {
        fields: ['username', 'title', 'description', 'basicDescription', 'basicTitle', 'categories', 'subCategories', 'tags'],
        like: [
          {
            _index: 'gigs',
            _id: gigId
          }
        ]
      }
    }
  });
  const total: IHitsTotal = result.hits.total as IHitsTotal;
  return {
    total: total.value,
    hits: result.hits.hits
  };
};

/**
 * @description Obtiene los gigs mejor calificados (rating de 5 estrellas) para una categoría específica.
 * @param {string} searchQuery - La categoría para filtrar los gigs mejor calificados.
 * @returns {Promise<ISearchResult>} - Una promesa que resuelve a un objeto con el total de resultados y los hits de la búsqueda.
 */
const getTopRatedGigsByCategory = async (searchQuery: string): Promise<ISearchResult> => {
  const result: SearchResponse = await elasticSearchClient.search({
    index: 'gigs',
    size: 10,
    query: {
      bool: {
        filter: {
          script: {
            script: {
              source: 'doc[\'ratingSum\'].value != 0 && (doc[\'ratingSum\'].value / doc[\'ratingsCount\'].value == params[\'threshold\'])',
              lang: 'painless',
              params: {
                threshold: 5
              }
            }
          }
        },
        must: [
          {
            query_string: {
              fields: ['categories'],
              query: `*${searchQuery}*`
            }
          }
        ]
      }
    }
  });
  const total: IHitsTotal = result.hits.total as IHitsTotal;
  return {
    total: total.value,
    hits: result.hits.hits
  };
};

export {
  gigsSearchBySellerId,
  gigsSearch,
  gigsSearchByCategory,
  getMoreGigsLikeThis,
  getTopRatedGigsByCategory
};