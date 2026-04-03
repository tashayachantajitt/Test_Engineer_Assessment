import pytest
from playwright.sync_api import Playwright

# Note: ReqRes API currently returns 401 Unauthorized for requests. 
# Using https://dummyjson.com as an alternative stable environment for this assignment.

BASE_URL = "https://dummyjson.com/users/"

def test_get_user_profile_success(playwright: Playwright):
    request_context = playwright.request.new_context()
    
    response = request_context.get(f"{BASE_URL}12")

    #1. Verify response status code should be ‘200’
    assert response.status == 200
    user = response.json()

    #2. Compare the response body with expected below.
    assert user["id"] == 12
    assert user["email"] == "mia.rodriguez@x.dummyjson.com"
    assert user["firstName"] == "Mia"
    assert user["lastName"] == "Rodriguez"
    assert user["image"] == "https://dummyjson.com/icon/miar/128"

    print("Test case : Get user profile success.")

def test_get_user_profile_not_found(playwright: Playwright):
    request_context = playwright.request.new_context()
    
    response = request_context.get(f"{BASE_URL}1234")
    #1. Verify response status code should be ‘404’.
    assert response.status == 404
    response_body = response.json()
    
    #2. Response body [message] should not null.
    assert "message" in response_body
    assert response_body["message"] != ""
    #print(f"\nError Message found: {response_body['message']}")

    print("Test case : Get user profile but user not found.")
