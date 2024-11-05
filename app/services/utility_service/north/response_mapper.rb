module UtilityService
  module North
    class ResponseMapper < UtilityService::ResponseMapper
      def retrieve_books(_response_code, response_body)
        { books: map_books(response_body['libros']) }
      end

      def retrieve_notes(_response_code, response_body)
        { notes: map_notes(response_body['notas']) }
      end

      private

      def map_books(books)
        books.map do |book|
          {
            id: book['id'],
            title: book['titulo'],
            author: book['autor'],
            genre: book['genero'],
            image_url: book['imagen_url'],
            publisher: book['editorial'],
            year: book['año']
          }
        end
      end

      def map_notes(notes)
        notes.map do |note|
          {
            id: note['id'],
            title: note['titulo'],
            #type: map_note_type[note['tipo']],
            created_at: note['fecha_creacion'],
            content: note['contenido'],
            #user: map_note_user(note),
            book: map_note_book(note['libro'])
          }
        end
      end

      def map_note_book(book)
        {
          title: book['titulo'],
          author: book['autor'],
          genre: book['genero']
        }
      end
    end
  end
end
