shared_examples 'bad note creation' do
  it 'does not create a note' do
    expect { create_note }.not_to change(Note, :count)
  end

  it 'responds with an error message' do
    create_note
    expect(response_body['error']).to eq(message)
  end
end
