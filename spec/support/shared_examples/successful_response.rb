shared_examples 'successful response' do
  it 'responds with the correct keys' do
    expect(respond_keys).to eq(expected_keys)
  end

  it 'responds with 200 status' do
    expect(response).to have_http_status(:ok)
  end
end
