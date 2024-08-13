# Pact Support

![Build status](https://github.com/pact-foundation/pact-support/workflows/Test/badge.svg)

Provides shared code for the Pact gems

## Supported matching rules

| matcher       | Spec Version | Implemented | Usage|
|---------------|--------------|-------------|-------------|
| Equality      | V1           |   |    |
| Regex         | V2           | ✅  | `Pact.term(generate, matcher)` |
| Type          | V2           | ✅  | `Pact.like(generate)` |
| MinType       | V2           | ✅  | `Pact.each_like(generate, min: <val>)` |
| MaxType       | V2           |   |    |
| MinMaxType    | V2           |   |    |
| Include       | V3           |   |    |
| Integer       | V3           |   |    |
| Decimal       | V3           |   |    |
| Number        | V3           |   |    |
| Timestamp     | V3           |   |    |
| Time          | V3           |   |    |
| Date          | V3           |   |    |
| Null          | V3           |   |    |
| Boolean       | V3           |   |    |
| ContentType   | V3           |   |    |
| Values        | V3           |   |    |
| ArrayContains | V4           |   |    |
| StatusCode    | V4           |   |    |
| NotEmpty      | V4           |   |    |
| Semver        | V4           |   |    |
| EachKey       | V4           |   |    |
| EachValue     | V4           |   |    |

## Supported generators

| matcher                | Spec Version | Implemented |
|------------------------|--------------|----|
| RandomInt              | V3           | ✅ |
| RandomDecimal          | V3           | ✅ |
| RandomHexadecimal      | V3           | ✅ |
| RandomString           | V3           | ✅ |
| Regex                  | V3           | ✅ |
| Uuid                   | V3/V4        | ✅ |
| Date                   | V3           | ✅ |
| Time                   | V3           | ✅ |
| DateTime               | V3           | ✅ |
| RandomBoolean          | V3           | ✅ |
| ProviderState          | V4           | ✅ |
| MockServerURL          | V4           | 🚧 |
