import { IconButton } from '@mui/material';
import { CSVLink } from 'react-csv';
import FileDownloadIcon from '@mui/icons-material/FileDownload';
import { useState } from 'react';

export default function CsvMultiDownloadLink({ title1, title2, data, token }) {
  const [downloadData, setDownloadData] = useState([]);

  console.log(token);

  const headers = [
    { label: 'Day', key: 'ts' },
    { label: title1, key: 'v' },
    { label: title2, key: 'v2' },
  ];

  // console.log(data);
  const transformData = (_event, done) => {
    const dd = data.map(aa => {
      return {
        ts: new Date(aa.ts * 1000).toLocaleDateString(),
        v: aa.v,
        v2: aa[token],
      };
    });
    setDownloadData(dd);
    done();
  };

  return (
    <CSVLink
      asyncOnClick={true}
      onClick={transformData}
      data={downloadData}
      headers={headers}
      target="_blank"
      filename={title1 + ' ' + title2 + '.csv'}
    >
      <IconButton color="primary">
        <FileDownloadIcon />
      </IconButton>
    </CSVLink>
  );
}
