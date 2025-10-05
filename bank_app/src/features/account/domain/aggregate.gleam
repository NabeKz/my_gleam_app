pub type AccountEvent {
  Created
  Upped
  Downed
}

pub opaque type Account {
  Account(id: String, value: Int)
}

pub fn new(id: String) -> Account {
  Account(id, 0)
}

pub fn handle(account: Account, message: AccountEvent) -> Account {
  case message {
    Created -> Account(account.id, 0)
    Upped -> Account(account.id, account.value + 1)
    Downed -> Account(account.id, account.value - 1)
  }
}

pub fn replay(account: Account, events: List(AccountEvent)) -> Account {
  case events {
    [] -> account
    [message, ..rest] -> {
      account
      |> handle(message)
      |> replay(rest)
    }
  }
}

pub fn value(self: Account) -> Int {
  self.value
}
