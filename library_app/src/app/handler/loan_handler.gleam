import gleam/json
import wisp

import features/loan/usecase
import shared/date
import shared/domain/book_id

pub fn loan(
  req: wisp.Request,
  loan_book: usecase.LoanBook,
  book_id: String,
  due_date: String,
) {
  // TODO: パラメータのパースとバリデーション
  let book_id_result = book_id.from_string(book_id)
  let due_date_result = date.from_string(due_date)

  case due_date_result {
    Ok(parsed_due_date) -> {
      let result =
        usecase.compose_loan_book(loan_book, book_id_result, parsed_due_date)

      case result {
        Ok(_) -> {
          "loan created"
          |> json.string()
          |> json.to_string_tree()
          |> wisp.json_response(201)
        }
        Error(error) -> {
          error
          |> json.string()
          |> json.to_string_tree()
          |> wisp.json_response(400)
        }
      }
    }
    Error(_) -> {
      "invalid due_date format"
      |> json.string()
      |> json.to_string_tree()
      |> wisp.json_response(400)
    }
  }
}

pub fn return_book(
  req: wisp.Request,
  return_book: usecase.ReturnBook,
  book_id: String,
) {
  let book_id_result = book_id.from_string(book_id)
  let result = usecase.compose_return_book(return_book, book_id_result)

  case result {
    Ok(_) -> {
      "book returned"
      |> json.string()
      |> json.to_string_tree()
      |> wisp.json_response(200)
    }
    Error(error) -> {
      error
      |> json.string()
      |> json.to_string_tree()
      |> wisp.json_response(400)
    }
  }
}

pub fn get_loan(req: wisp.Request, get_loan: usecase.GetLoan, book_id: String) {
  let book_id_result = book_id.from_string(book_id)
  let result = usecase.compose_get_loan(get_loan, book_id_result)

  case result {
    Ok(loan) -> {
      // TODO: loanをJSONに変換
      "loan found"
      |> json.string()
      |> json.to_string_tree()
      |> wisp.json_response(200)
    }
    Error(error) -> {
      error
      |> json.string()
      |> json.to_string_tree()
      |> wisp.json_response(404)
    }
  }
}
