terraform {
  backend "gcs" {
    bucket  = "tfstate-loyal-road-353919-tfstate"
    prefix  = "terraform/state"
    credentials = "loyal-road-353919-27ba2e9f8be1.json"
	  }
}