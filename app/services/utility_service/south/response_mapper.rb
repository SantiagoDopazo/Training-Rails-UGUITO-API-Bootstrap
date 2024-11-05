module UtilityService
  module South
    class ResponseMapper < UtilityService::ResponseMapper
      def retrieve_books(_response_code, response_body)
        { books: map_books(response_body['Libros']) }
      end

      def retrieve_notes(_response_code, response_body)
        { notes: map_notes(response_body['Notas']) }
      end

      private

      def map_books(books)
        books.map do |book|
          {
            id: book['Id'],
            title: book['Titulo'],
            author: book['Autor'],
            genre: book['Genero'],
            image_url: book['ImagenUrl'],
            publisher: book['Editorial'],
            year: book['Año']
          }
        end
      end

      def map_notes(notes)
        notes.map do |note|
          {
            id: note['Id'],
            title: note['TituloNota'],
            note_type: note['ReseniaNota'] ? 'review' : 'critique',
            created_at: note['FechaCreacionNota'],
            content: note['Contenido'],
            book: map_note_book(note)
            #user: map_note_user(note)
          }
        end
      end

      def map_note_book(note)
        {
          title: note['TituloLibro'],
          author: note['NombreAutorLibro'],
          genre: note['GeneroLibro']
        }
      end

      def map_note_user
        {
          email: note['EmailAutor']

        }
      end
    end
  end
end
