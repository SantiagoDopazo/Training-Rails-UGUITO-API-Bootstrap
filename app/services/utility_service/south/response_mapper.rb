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
            note_type: transform_note_type(note),
            created_at: note['FechaCreacionNota'],
            content: note['Contenido'],
            user: map_note_user(note),
            book: map_note_book(note)
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

      def map_note_user(note)
        {
          first_name: first_name_selector(note),
          last_name: last_name_selector(note),
          email: note['EmailAutor']
        }
      end

      def transform_note_type(note)
        note['ReseniaNota'] ? 'review' : 'critique'
      end

      def divide_name(note)
        note['NombreCompletoAutor'].split
      end

      def first_name_selector(note)
        divide_name(note).last
      end

      def last_name_selector(note)
        divide_name(note).first
      end
    end
  end
end
