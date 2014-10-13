import re

PDB = re.compile('^[0-9][A-z0-9]{3}$')


class ValidationError(Exception):
    """Raised when a search is invalid or cannot be santized.
    """
    pass


def santize_search(search):
    pass


def santize_given(given):
    data = {pdbs: {}, cells: {}, size: []}

    for raw in given.get('pdbs', []):
        for pdb in raw.split(','):
            if PDB.match(pdb):
                data['pdbs'][pdb] = True

    if given['size']:
        size = given['size'].split(',')
        data['size'] = (size[0], size[1])
        (row_count, col_count) = data['size']

        rows = given.get('rows', [])
        if len(rows) > row_count:
            rows = rows[0:row_count]

        if len(rows) < row_count:
            empty_row = ','.join([''] * col_count)
            rows.extend([empty_row] * (row_count - len(rows)))

        for row in given.get('rows', []):
            cells = row.split(',')
            if len(cells) > col_count:
                cells = cells[0:col_count]
            if len(cells) < col_count:
                cells.extend([None] * (col_count - len(cells)))

            for cell in cells:
                if cell == '':
                    cell = None
                data['cells'][row][column] = cell

    return data
