import { IconButton } from '@mui/material';
import { CSVLink } from 'react-csv';
import FileDownloadIcon from '@mui/icons-material/FileDownload';
import { useState } from 'react';

export default function CsvDownloadLink({ title, data }) {
  const [downloadData, setDownloadData] = useState([]);

  const headers = [
    { label: 'Day', key: 'ts' },
    { label: title, key: 'v' },
  ];

  const transformData = (_event, done) => {
    const dd = data.map(aa => {
      return { ts: new Date(aa.ts * 1000).toLocaleDateString(), v: aa.v };
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
      filename={title + '.csv'}
    >
      <IconButton color="primary">
        <FileDownloadIcon />
      </IconButton>
    </CSVLink>
  );
}
