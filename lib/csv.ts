/**
 * One CSV cell, quoted. Text that a spreadsheet would read as a formula
 * (starting with = + - @, a tab or a carriage return) gets a leading
 * apostrophe, because lead names and notes come from public forms and must
 * not run as formulas when the export is opened in Excel or Sheets.
 */
export function csvCell(value: unknown) {
  let text = value == null ? "" : String(value);
  if (/^[=+\-@\t\r]/.test(text)) text = `'${text}`;
  return `"${text.replaceAll('"', '""')}"`;
}
