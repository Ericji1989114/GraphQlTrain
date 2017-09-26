//  This file was automatically generated and should not be edited.

import Apollo

public final class RestaurantQuery: GraphQLQuery {
  public static let operationDefinition =
    "query Restaurant {" +
    "  restaurant(query: {match: {name: {query: \"目黒\"}}}, limit: 10) {" +
    "    __typename" +
    "    hits {" +
    "      __typename" +
    "      _source {" +
    "        __typename" +
    "        name" +
    "        address" +
    "      }" +
    "    }" +
    "    count" +
    "    aggregations" +
    "    max_score" +
    "    took" +
    "    timed_out" +
    "  }" +
    "}"
  public init() {
  }

  public struct Data: GraphQLMappable {
    public let restaurant: Restaurant?

    public init(reader: GraphQLResultReader) throws {
      restaurant = try reader.optionalValue(for: Field(responseName: "restaurant", arguments: ["query": ["match": ["name": ["query": "目黒"]]], "limit": 10]))
    }

    public struct Restaurant: GraphQLMappable {
      public let __typename: String
      public let hits: [Hit?]?
      public let count: Int?
      public let aggregations: String?
      public let maxScore: Double?
      public let took: Int?
      public let timedOut: Bool?

      public init(reader: GraphQLResultReader) throws {
        __typename = try reader.value(for: Field(responseName: "__typename"))
        hits = try reader.optionalList(for: Field(responseName: "hits"))
        count = try reader.optionalValue(for: Field(responseName: "count"))
        aggregations = try reader.optionalValue(for: Field(responseName: "aggregations"))
        maxScore = try reader.optionalValue(for: Field(responseName: "max_score"))
        took = try reader.optionalValue(for: Field(responseName: "took"))
        timedOut = try reader.optionalValue(for: Field(responseName: "timed_out"))
      }

      public struct Hit: GraphQLMappable {
        public let __typename: String
        /// Elasticsearch mapping does not contains info about is field plural or not. So `propName` is singular and returns value or first value from array. `propNameA` is plural and returns array of values.
        public let source: Source?

        public init(reader: GraphQLResultReader) throws {
          __typename = try reader.value(for: Field(responseName: "__typename"))
          source = try reader.optionalValue(for: Field(responseName: "_source"))
        }

        public struct Source: GraphQLMappable {
          public let __typename: String
          public let name: String?
          public let address: String?

          public init(reader: GraphQLResultReader) throws {
            __typename = try reader.value(for: Field(responseName: "__typename"))
            name = try reader.optionalValue(for: Field(responseName: "name"))
            address = try reader.optionalValue(for: Field(responseName: "address"))
          }
        }
      }
    }
  }
}